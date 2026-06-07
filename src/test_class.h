#ifndef TEST_CLASS_H
#define TEST_CLASS_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/core/binder_common.hpp>  // 可选，有时需要

namespace godot {

class TestClass : public Node {
    GDCLASS(TestClass, Node)

private:
    int score;

protected:
    static void _bind_methods();

public:
    TestClass();
    ~TestClass();

    void set_score(int p_score);
    int get_score() const;
    void print_message(String message);
};

}

#endif