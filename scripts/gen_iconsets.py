import json, collections, io

src = json.load(open('/tmp/qbase/iconsets.json'))
order = ['material-icons','material-icons-outlined','material-icons-round','material-icons-sharp',
         'material-symbols-rounded','material-symbols-outlined','material-symbols-sharp',
         'mdi-v7','ionicons-v4','eva-icons','fontawesome-v6','themify','bootstrap-icons','line-awesome']
out = collections.OrderedDict()
for k in order:
    if k in src:
        d = dict(src[k])
        d.pop('set', None)
        out[k] = d

buf = io.StringIO()
buf.write('// src/pyside_nova/qml/Nova/Design/IconSets.js\n')
buf.write('// 图标集数据表（L0）：14 套 Quasar 官方 icon-set 全键 1:1 移植，键路径与 npm quasar@2.35.5 icon-set/*.js 逐项一致\n')
buf.write('// 生成物：scripts/gen_iconsets.py 从基线包提取，勿手改；新增自定义图标集请在 NovaIconSet.register() 运行时注册\n')
buf.write('.pragma library\n\n')
buf.write('var sets = {\n')
for name, d in out.items():
    buf.write('    %s: %s,\n' % (json.dumps(name), json.dumps(d, ensure_ascii=False, separators=(',', ':'))))
buf.write('}\n\n')
buf.write('function names() { return Object.keys(sets) }\n\n')
buf.write('function get(name) { return sets[name] !== undefined ? sets[name] : null }\n\n')
buf.write('function paths() { return __base }\n\n')
# 全键路径清单（基准 mdi-v7）
def leaves(o, prefix, acc):
    for k, v in o.items():
        if k == 'name':
            continue
        p = prefix + '.' + k if prefix else k
        if isinstance(v, dict): leaves(v, p, acc)
        else: acc.append(p)
    return acc
base = leaves(out['mdi-v7'], '', [])
buf.write('// 语义键全集（100 项，mdi-v7 为基准 19 组；material 系缺 editor.heading1~6 / editor.size1~7 共 13 项，基线允许回落 heading/size）\n')
buf.write('var __base = %s\n' % json.dumps(base, ensure_ascii=False, separators=(',', ':')))
open('src/pyside_nova/qml/Nova/Design/IconSets.js','w').write(buf.getvalue())
print('sets:', len(out), 'bytes:', len(buf.getvalue()))
print('base paths:', len(base))
