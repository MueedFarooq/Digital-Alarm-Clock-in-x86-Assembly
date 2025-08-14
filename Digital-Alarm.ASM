.model small
.stack 100h

.data
    ; Time variables
    current_hour    db 0
    current_minute  db 0
    current_second  db 0
    
    ; Alarm variables
    alarm_hour      db 255     ; 255 = no alarm set
    alarm_minute    db 255
    alarm_enabled   db 0       ; 0 = disabled, 1 = enabled
    
    ; Display strings
    time_str        db '00:00:00$'
    alarm_str       db 'Alarm: OFF    $'
    menu_str        db 'Press S to set alarm, ESC to exit$'
    set_alarm_msg   db 'Set alarm time (HH:MM): $'
    alarm_msg       db '*** ALARM! Press any key to stop ***$'
    invalid_msg     db 'Invalid time format! Press any key...$'
    
    ; Input buffer
    input_buffer    db 6, 0, 6 dup(0)
    
    ; Constants
    ESC_KEY         equ 1Bh
    ENTER_KEY       equ 0Dh

.code
main proc
    mov ax, @data
    mov ds, ax
    
    ; Hide cursor
    mov ah, 01h
    mov cx, 2000h
    int 10h
    
main_loop:
    ; Clear screen
    call clear_screen
    
    ; Get current time
    call get_time
    
    ; Check if alarm should trigger
    call check_alarm
    
    ; Display time
    call display_time
    
    ; Display alarm status
    call display_alarm_status
    
    ; Display menu
    call display_menu
    
    ; Check for key press
    call check_key_press
    
    ; Wait approximately 1 second
    call delay_one_second
    
    jmp main_loop

exit_program:
    ; Show cursor
    mov ah, 01h
    mov cx, 0607h
    int 10h
    
    ; Exit to DOS
    mov ax, 4C00h
    int 21h
main endp

; Get current time from system
get_time proc
    mov ah, 2Ch        ; Get system time
    int 21h            ; CH=hour, CL=minute, DH=second, DL=hundredths
    
    mov current_hour, ch
    mov current_minute, cl
    mov current_second, dh
    ret
get_time endp

; Set alarm time
set_alarm proc
    push ax
    push bx
    push cx
    push dx
    
    ; Clear screen
    call clear_screen
    
    ; Display prompt
    mov ah, 09h
    mov dx, offset set_alarm_msg
    int 21h
    
    ; Get input
    mov ah, 0Ah
    mov dx, offset input_buffer
    int 21h
    
    ; Parse input (HH:MM format)
    mov si, offset input_buffer + 2
    
    ; Check if input length is 5
    cmp byte ptr [input_buffer + 1], 5
    jne invalid_input
    
    ; Parse hour (first two digits)
    mov al, [si]        ; Get first digit
    sub al, '0'
    cmp al, 9
    ja invalid_input
    mov bl, al          ; bl = first digit (0-9)
    
    mov al, [si + 1]    ; Get second digit
    sub al, '0'
    cmp al, 9
    ja invalid_input
    
    ; Calculate: hour = first_digit * 10 + second_digit
    mov al, bl          ; al = first digit
    mov cl, 10
    mul cl              ; al = first_digit * 10
    mov bl, [si + 1]    ; Get second digit again
    sub bl, '0'
    add al, bl          ; al = first_digit*10 + second_digit
    
    cmp al, 23
    ja invalid_input
    mov alarm_hour, al
    
    ; Check colon
    cmp byte ptr [si + 2], ':'
    jne invalid_input
    
    ; Parse minute (last two digits)
    mov al, [si + 3]    ; Get first digit of minute
    sub al, '0'
    cmp al, 9
    ja invalid_input
    mov bl, al          ; bl = first digit (0-9)
    
    mov al, [si + 4]    ; Get second digit of minute
    sub al, '0'
    cmp al, 9
    ja invalid_input
    
    ; Calculate: minute = first_digit * 10 + second_digit
    mov al, bl          ; al = first digit
    mov cl, 10
    mul cl              ; al = first_digit * 10
    mov bl, [si + 4]    ; Get second digit again
    sub bl, '0'
    add al, bl          ; al = first_digit*10 + second_digit
    
    cmp al, 59
    ja invalid_input
    mov alarm_minute, al
    
    ; Enable alarm
    mov alarm_enabled, 1
    
    jmp set_alarm_done

invalid_input:
    ; Clear screen
    call clear_screen
    
    ; Display error message
    mov ah, 09h
    mov dx, offset invalid_msg
    int 21h
    
    ; Wait for key press
    mov ah, 00h
    int 16h

set_alarm_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
set_alarm endp

; Check if alarm should trigger
check_alarm proc
    push ax
    push bx
    
    ; Check if alarm is enabled
    cmp alarm_enabled, 1
    jne check_alarm_done
    
    ; Check if current time matches alarm time
    mov al, current_hour
    cmp al, alarm_hour
    jne check_alarm_done
    
    mov al, current_minute
    cmp al, alarm_minute
    jne check_alarm_done
    
    ; Trigger alarm
    call trigger_alarm

check_alarm_done:
    pop bx
    pop ax
    ret
check_alarm endp

; Trigger alarm
trigger_alarm proc
    push ax
    push bx
    push cx
    push dx
    
    ; Disable alarm to prevent continuous triggering
    mov alarm_enabled, 0
    
alarm_loop:
    ; Clear screen
    call clear_screen
    
    ; Position cursor in center
    mov ah, 02h
    mov bh, 0
    mov dh, 12
    mov dl, 20
    int 10h
    
    ; Display alarm message
    mov ah, 09h
    mov dx, offset alarm_msg
    int 21h
    
    ; Make beep sound
    mov ah, 02h
    mov dl, 07h    ; Bell character
    int 21h
    
    ; Check for key press
    mov ah, 01h
    int 16h
    jz alarm_continue
    
    ; Key pressed, consume it and exit alarm
    mov ah, 00h
    int 16h
    jmp alarm_done
    
alarm_continue:
    ; Small delay
    mov cx, 0FFFFh
delay_loop:
    loop delay_loop
    
    jmp alarm_loop

alarm_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
trigger_alarm endp

; Display current time
display_time proc
    push ax
    push bx
    push cx
    push dx
    
    ; Position cursor
    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 30
    int 10h
    
    ; Convert and display time
    mov si, offset time_str
    
    ; Hour
    mov al, current_hour
    call convert_to_ascii
    mov [si], ah
    mov [si + 1], al
    
    ; Minute
    mov al, current_minute
    call convert_to_ascii
    mov [si + 3], ah
    mov [si + 4], al
    
    ; Second
    mov al, current_second
    call convert_to_ascii
    mov [si + 6], ah
    mov [si + 7], al
    
    ; Display time string
    mov ah, 09h
    mov dx, offset time_str
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_time endp

; Display alarm status
display_alarm_status proc
    push ax
    push bx
    push cx
    push dx
    
    ; Position cursor
    mov ah, 02h
    mov bh, 0
    mov dh, 7
    mov dl, 30
    int 10h
    
    ; Check if alarm is enabled
    cmp alarm_enabled, 1
    jne display_alarm_off
    
    ; Display alarm time
    mov si, offset alarm_str
    mov byte ptr [si], 'A'
    mov byte ptr [si + 1], 'l'
    mov byte ptr [si + 2], 'a'
    mov byte ptr [si + 3], 'r'
    mov byte ptr [si + 4], 'm'
    mov byte ptr [si + 5], ':'
    mov byte ptr [si + 6], ' '
    
    ; Convert alarm hour
    mov al, alarm_hour
    call convert_to_ascii
    mov [si + 7], ah
    mov [si + 8], al
    
    mov byte ptr [si + 9], ':'
    
    ; Convert alarm minute
    mov al, alarm_minute
    call convert_to_ascii
    mov [si + 10], ah
    mov [si + 11], al
    
    mov byte ptr [si + 12], ' '
    mov byte ptr [si + 13], '$'
    
    jmp display_alarm_show

display_alarm_off:
    ; Reset alarm string to "OFF"
    mov si, offset alarm_str
    mov byte ptr [si], 'A'
    mov byte ptr [si + 1], 'l'
    mov byte ptr [si + 2], 'a'
    mov byte ptr [si + 3], 'r'
    mov byte ptr [si + 4], 'm'
    mov byte ptr [si + 5], ':'
    mov byte ptr [si + 6], ' '
    mov byte ptr [si + 7], 'O'
    mov byte ptr [si + 8], 'F'
    mov byte ptr [si + 9], 'F'
    mov byte ptr [si + 10], ' '
    mov byte ptr [si + 11], ' '
    mov byte ptr [si + 12], ' '
    mov byte ptr [si + 13], '$'

display_alarm_show:
    ; Display alarm string
    mov ah, 09h
    mov dx, offset alarm_str
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_alarm_status endp

; Display menu
display_menu proc
    push ax
    push bx
    push cx
    push dx
    
    ; Position cursor
    mov ah, 02h
    mov bh, 0
    mov dh, 20
    mov dl, 15
    int 10h
    
    ; Display menu string
    mov ah, 09h
    mov dx, offset menu_str
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_menu endp

; Check for key press
check_key_press proc
    push ax
    push bx
    push cx
    push dx
    
    ; Check if key is available
    mov ah, 01h
    int 16h
    jz check_key_done
    
    ; Get key
    mov ah, 00h
    int 16h
    
    ; Check for ESC
    cmp al, ESC_KEY
    jne check_s_key
    jmp near ptr exit_program

check_s_key:
    
    ; Check for 'S' or 's'
    cmp al, 'S'
    je set_alarm_key
    cmp al, 's'
    je set_alarm_key
    
    jmp check_key_done

set_alarm_key:
    call set_alarm

check_key_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
check_key_press endp

; Convert number to ASCII (AL -> AH=tens, AL=ones)
convert_to_ascii proc
    push bx
    push dx
    
    mov ah, 0
    mov bl, 10
    div bl
    add ah, '0'
    add al, '0'
    xchg ah, al
    
    pop dx
    pop bx
    ret
convert_to_ascii endp

; Clear screen
clear_screen proc
    push ax
    push bx
    push cx
    push dx
    
    mov ax, 0600h      ; Scroll up function
    mov bh, 07h        ; Normal attribute
    mov cx, 0000h      ; Upper left corner
    mov dx, 184Fh      ; Lower right corner (24,79)
    int 10h
    
    ; Set cursor to home position
    mov ah, 02h
    mov bh, 0
    mov dx, 0
    int 10h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
clear_screen endp

; Delay approximately 1 second
delay_one_second proc
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 15         ; Outer loop count
outer_delay:
    mov dx, 0FFFFh     ; Inner loop count
inner_delay:
    dec dx
    jnz inner_delay
    loop outer_delay
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
delay_one_second endp

end main