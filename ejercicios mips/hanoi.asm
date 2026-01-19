.data
    prompt: .asciiz "Ingrese el numero de discos: "
    msg1:   .asciiz "Mover disco de "
    msg2:   .asciiz " a "
    newline: .asciiz "\n"

.text
.main:
    
    li $v0, 4
    la $a0, prompt
    syscall

    li $v0, 5
    syscall
    move $s0, $v0      # $s0 = n 

  
    move $a0, $s0      # $a0 = n
    li $a1, 1          # Torre 1 (Origen)
    li $a2, 3          # Torre 3 (Destino)
    li $a3, 2          # Torre 2 (Auxiliar)

    jal hanoi         

   
    li $v0, 10
    syscall


hanoi:

    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $a1, 8($sp)
    sw $a2, 4($sp)
    sw $a3, 0($sp)

    move $s0, $a0      # $s0 = n actual

    # Caso base: si n == 1
    li $t0, 1
    beq $s0, $t0, mover_un_disco

    # Paso recursivo 1: hanoi(n-1, origen, auxiliar, destino)
    addi $a0, $s0, -1
   
    move $t1, $a2
    move $a2, $a3
    move $a3, $t1
    jal hanoi

    # Cargar valores originales después de la recursión para el paso central
    lw $a1, 8($sp)
    lw $a2, 4($sp)
    jal imprimir_paso

    # Paso recursivo 2: hanoi(n-1, auxiliar, destino, origen)
    lw $a0, 12($sp)    # Cargar n original
    addi $a0, $a0, -1  # n - 1
    lw $a1, 0($sp)     # El auxiliar original ahora es el origen
    lw $a2, 4($sp)     # El destino original se mantiene
    lw $a3, 8($sp)     # El origen original ahora es el auxiliar
    jal hanoi

    j hanoi_ret

mover_un_disco:
    jal imprimir_paso

hanoi_ret:

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    addi $sp, $sp, 20
    jr $ra


imprimir_paso:
    li $v0, 4
    la $a0, msg1
    syscall

    li $v0, 1
    move $a0, $a1      # Imprimir torre origen
    syscall

    li $v0, 4
    la $a0, msg2
    syscall

    li $v0, 1
    move $a0, $a2      # Imprimir torre destino
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    jr $ra
