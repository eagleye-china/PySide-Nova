# src/pyside_nova/bridge/chat_bridge.py

import datetime
import json
import os
import shutil

from openai import OpenAI
from PySide6.QtCore import QObject, QThread, QSettings, Signal, Slot

SYSTEM_PROMPT_TEMPLATE = """
你是 PySide-Nova 框架的首席 AI 架构师。PySide-Nova 是一个基于 PySide6 + QML 的企业级 UI 组件库，专为工业 HMI、大屏和数据密集型应用设计。

当前系统时间已校准为：{current_time}
"""


class ChatWorker(QThread):
    chunk_received = Signal(str)
    action_log = Signal(str)
    finished_signal = Signal()
    error_signal = Signal(str)

    def __init__(self, messages, project_root="."):
        super().__init__()
        self.messages = messages
        self.project_root = project_root
        self._is_running = True

        # 从 QSettings 读取配置
        settings = QSettings("NovaFramework", "NovaOrbit")
        self.api_key = settings.value("api_key", "sk-7614008b561344ea980b3164712c44c1")
        self.base_url = settings.value("base_url", "https://api.deepseek.com")
        self.model = settings.value("model", "deepseek-chat")

        self.tools = [
            {
                "type": "function",
                "function": {
                    "name": "read_file",
                    "description": "读取项目中的文件内容。",
                    "parameters": {
                        "type": "object",
                        "properties": {"file_path": {"type": "string", "description": "相对路径"}},
                        "required": ["file_path"]
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "write_multiple_files",
                    "description": "将生成的代码同时写入到多个指定的项目文件中。",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "files": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "file_path": {"type": "string"},
                                        "code": {"type": "string"}
                                    },
                                    "required": ["file_path", "code"]
                                }
                            }
                        },
                        "required": ["files"]
                    }
                }
            }
        ]

    def stop(self):
        self._is_running = False

    def _read_file(self, file_path):
        full_path = os.path.join(self.project_root, file_path)
        if not os.path.exists(full_path):
            return f"错误: 文件 {file_path} 不存在。"
        try:
            with open(full_path, encoding="utf-8") as f:
                return f.read()
        except Exception as e:
            return f"读取失败: {str(e)}"

    def _write_files(self, files_list):
        results = []
        for item in files_list:
            file_path = item.get("file_path", "")
            code = item.get("code", "")
            if not file_path or not code:
                continue

            full_path = os.path.join(self.project_root, file_path)
            os.makedirs(os.path.dirname(full_path), exist_ok=True)

            if os.path.exists(full_path):
                shutil.copy2(full_path, full_path + ".bak")
                self.action_log.emit(f"⚠️ 已备份旧文件: {file_path}.bak")

            with open(full_path, "w", encoding="utf-8") as f:
                f.write(code)
            results.append(file_path)
        return f"成功写入文件: {', '.join(results)}"

    def run(self):
        try:
            client = OpenAI(api_key=self.api_key, base_url=self.base_url)
            now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            system_prompt = SYSTEM_PROMPT_TEMPLATE.replace("{current_time}", now)
            final_messages = [{"role": "system", "content": system_prompt}] + self.messages

            write_count = 0

            while self._is_running:
                response = client.chat.completions.create(
                    model=self.model,
                    messages=final_messages,
                    tools=self.tools,
                    stream=True
                )

                tool_calls_buffer = {}
                has_tool_calls = False
                full_content = ""

                for chunk in response:
                    if not self._is_running:
                        break
                    delta = chunk.choices[0].delta

                    # 流式文本
                    if delta.content:
                        full_content += delta.content
                        self.chunk_received.emit(delta.content)

                    # 流式工具调用（拼接碎片）
                    if delta.tool_calls:
                        has_tool_calls = True
                        for tc in delta.tool_calls:
                            idx = tc.index
                            if idx not in tool_calls_buffer:
                                tool_calls_buffer[idx] = {
                                    "id": tc.id, "type": "function", "function": {"name": "", "arguments": ""}
                                }
                            if tc.function.name:
                                tool_calls_buffer[idx]["function"]["name"] += tc.function.name
                            if tc.function.arguments:
                                tool_calls_buffer[idx]["function"]["arguments"] += tc.function.arguments

                if not self._is_running:
                    break

                # 如果有工具调用
                if has_tool_calls:
                    assistant_msg = {"role": "assistant", "content": full_content or ""}
                    assistant_msg["tool_calls"] = list(tool_calls_buffer.values())
                    self.messages.append(assistant_msg)
                    final_messages.append(assistant_msg)

                    for tc in assistant_msg["tool_calls"]:
                        name = tc["function"]["name"]
                        args_str = tc["function"]["arguments"]
                        tool_content = "执行失败"

                        try:
                            args = json.loads(args_str)
                            if name == "read_file":
                                self.action_log.emit(f"📖 正在读取: {args.get('file_path')}")
                                tool_content = self._read_file(args.get("file_path", ""))

                            elif name == "write_multiple_files":
                                write_count += 1
                                if write_count > 2:
                                    self.action_log.emit("⚠️ AI 陷入修改狂魔模式，强行终止！")
                                    self.chunk_received.emit("\n\n**【系统强制介入】** AI 反复写文件死循环，已中断。")
                                    self.finished_signal.emit()
                                    return

                                files = args.get("files", [])
                                names = [f.get("file_path") for f in files]
                                self.action_log.emit(f"🛠️ 写入文件: {', '.join(names)}")
                                tool_content = self._write_files(files)

                        except Exception as e:
                            tool_content = f"工具异常: {e}"

                        tool_msg = {"role": "tool", "tool_call_id": tc["id"], "content": tool_content}
                        self.messages.append(tool_msg)
                        final_messages.append(tool_msg)

                    self.action_log.emit("⏳ 正在请求下一步...")
                    continue

                if full_content:
                    self.messages.append({"role": "assistant", "content": full_content})
                self.finished_signal.emit()
                return

        except Exception as e:
            if self._is_running:
                self.error_signal.emit(str(e))


class ChatBridge(QObject):
    chunkReceived = Signal(str)  # noqa: N815
    actionLogged = Signal(str)  # noqa: N815
    replyFinished = Signal()  # noqa: N815
    replyError = Signal(str)  # noqa: N815

    def __init__(self):
        super().__init__()
        self.history = []
        self.worker = None

    @Slot(str)
    def sendMessage(self, text: str):
        if self.worker and self.worker.isRunning():
            return

        self.history.append({"role": "user", "content": text})

        # 传入项目根目录，让 AI 能够修改文件
        project_root = r"D:\MyProjects\PyCharm\Project_Nova\pyside-nova"

        self.worker = ChatWorker(self.history, project_root)
        self.worker.chunk_received.connect(self.chunkReceived)
        self.worker.action_log.connect(self.actionLogged)
        self.worker.finished_signal.connect(self.replyFinished)
        self.worker.error_signal.connect(self.replyError)
        self.worker.start()
