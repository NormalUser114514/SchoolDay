#include "test_class.h"
#include <godot_cpp/core/class_db.hpp>   // 添加这行：提供 ClassDB
#include <godot_cpp/variant/utility_functions.hpp>

namespace godot {

void TestClass::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_score", "score"), &TestClass::set_score);
    ClassDB::bind_method(D_METHOD("get_score"), &TestClass::get_score);
    ClassDB::bind_method(D_METHOD("print_message", "message"), &TestClass::print_message);
}

TestClass::TestClass() : score(0) {}
TestClass::~TestClass() {}

void TestClass::set_score(int p_score) { score = p_score; }
int TestClass::get_score() const { return score; }

void TestClass::print_message(String message) {
    UtilityFunctions::print("C++ says: ", message);
}

}  // namespace godot

// 初始化函数 - 注意这里也需要添加必要的头文件
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

extern "C" {
// 初始化入口点
GDExtensionBool GDE_EXPORT test_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, 
                                               GDExtensionClassLibraryPtr p_library, 
                                               GDExtensionInitialization *r_initialization) {
    godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
    
    // 注册初始化函数
    init_obj.register_initializer([](godot::ModuleInitializationLevel p_level) {
        if (p_level == godot::MODULE_INITIALIZATION_LEVEL_SCENE) {
            godot::ClassDB::register_class<godot::TestClass>();
        }
    });
    
    init_obj.set_minimum_library_initialization_level(godot::MODULE_INITIALIZATION_LEVEL_SCENE);
    return init_obj.init();
}
}