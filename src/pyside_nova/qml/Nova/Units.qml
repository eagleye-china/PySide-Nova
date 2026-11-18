pragma Singleton
import QtQuick

QtObject {
    // 保证 px() 函数存在，防止报 TypeError
    function px(val) {
        return val; 
    }
}
