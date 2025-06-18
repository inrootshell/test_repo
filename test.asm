org 0x7C00              ; 指定该程序的基地址为0x7c00 也就是BIOS程序执行完要跳转的位置 jmp 0x7c00:0000
bits 16                 ; 指定有以下汇编采用16位模

section .text           ; 代码段
    global start        ; 全局 start

start:                  ; main
    mov ax, 0x0000      ; 初始化ds的地址
    mov ds, ax          ; 将ax中的值存入ds中
    call clear_screen   ; 清除屏幕缓冲区
    mov si, info        ; 将字符串首地址存入si中方便print_info访问
    push cx             ; 保护cx get_str_len 会修改cx的值
    xchg bx, bx         ; 断点
    call get_str_len    ; 获取字符串长度
    call print_info     ; 打印信息
    pop cx              ; 还原cx
    jmp $               ; 死循环 $ 代表当前位置

clear_screen:
    xchg bx, bx
    push cx             ; 保存使用到的寄存器
    push ax
    push es
    push si
    mov cx, 0x0800      ; 循环次数
    mov ax, 0xb800      ; 显存地址
    mov es, ax          ; 使用es段寄存器来做基址
    xor si, si          ; si 从0开始偏移
    mov ax, 0x0000      ; 向显存中填充的数据 也可以优化成xor ax, ax
.clear_loop:
    mov es:[si], ax
    add si, 2           ; 每次写两个字节(word) 16位
    loop .clear_loop    ; 按照cx中的数值循环
    pop si              ; 使用后还原
    pop es
    pop ax
    pop cx
    xchg bx, bx

    ret

get_str_len:            ; ret_val cx get_str_len(si src) 可以优化返回值存储到栈中
    xchg bx, bx
    push ax
    push si
    xor ax, ax
    xor cx, cx          ; 由于要用到cx所以需要清空
.chcek_zero:
    mov al, ds:[si]     ; 将字符移动到al中
    cmp al, 0           ; 将al的值与0对比
    jz .done            ; 为0则代表字符串结尾 跳转至结束
    inc si              ; 获取下一个字符
    inc cx              ; 递增字符串长度
    jmp .chcek_zero
.done:                  ;结束代码 还原场景并且返回
    pop si
    pop ax
    xchg bx, bx

    ret

print_info:             ; print_info(si src, cx len)
    xchg bx, bx
    push es             ; 保护现场
    push ax
    push si
    push bx
    mov ax, 0xb800      ; 将显存地址移动到es
    mov es, ax
    xor ax, ax          ; 清理ax和bx寄存器
    xor bx, bx
    mov ah, 0x4f        ; 设置前景色为亮白 0x07为暗白 (低四位前景色高四位背景色)
.print_loop:            ; 通过 cx中存储的字符串长度确定循环次数
    mov al, ds:[si]     ; 将字符移动至al中
    mov es:[bx], ax     ; 一次写一个字的数据
    add bx, 2           ; 每次写一个字所以dx每次+=2
    inc si              ; si每次递增一次取下一个字符
    loop .print_loop    ; 根据cx中保存的字符串长度确定循环次数
    pop bx
    pop si              ; 还原现场
    pop ax
    pop es
    xchg bx, bx

    ret

str1 db "Hello World!", 0
info db "Loading System...", 0
msg db "Hello, Booter!", 0

times 510 - ($ - $$) db 0
dw 0xAA55               ; 引导扇区结束标志（正确的小端序）