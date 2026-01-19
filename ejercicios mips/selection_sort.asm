.data
    mensaje: .asciiz "ingrese numero: "
    esp:     .asciiz " "
    .align 2
    array:   .space 20

.text
main:
    la $s0, array
    li $s1, 0        # i
    li $s2, 5        # n 

llenar:
    beq $s1, $s2, reset
    li $v0, 4
    la $a0, mensaje
    syscall
    
    li $v0, 5
    syscall
    sw $v0, 0($s0)   
    
    addi $s0, $s0, 4
    addi $s1, $s1, 1
    j llenar

reset: 
    li $s1, 0        # i = 0
    li $s7, 4        # n - 1 

selection_sort:
for_ext:
    beq $s1, $s7, reset2  
    
    move $t0, $s1    # min_idx = i
    addi $t1, $s1, 1 # j = i + 1

for_int:
    li $t8, 5        # n 
    beq $t1, $t8, swap
    
   
    mul $t2, $t1, 4
    la $s0, array
    add $s3, $s0, $t2
    lw $t4, 0($s3)   # $t4 = array[j]
    
  
    mul $t3, $t0, 4
    add $s4, $s0, $t3
    lw $t5, 0($s4)   #$t5 = array[min_idx]
    

    bge $t4, $t5, next_j
    move $t0, $t1

next_j:
    addi $t1, $t1, 1
    j for_int

swap:

    mul $t2, $s1, 4
    la $s0, array
    add $s3, $s0, $t2 # Dir de array[i]
    lw $t4, 0($s3)    # Valor de array[i]
    
    mul $t3, $t0, 4
    add $s4, $s0, $t3 # Dir de array[min_idx]
    lw $t5, 0($s4)    # Valor de array[min_idx]
    
    sw $t5, 0($s3)    # array[i] = valor min
    sw $t4, 0($s4)    # array[min_idx] = valor i
    
    addi $s1, $s1, 1
    j for_ext

reset2: 
    la $s0, array
    li $s1, 0
    li $s2, 5       

imprimir:
    beq $s1, $s2, exit
    
    lw $a0, 0($s0)  
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, esp
    syscall
    
    addi $s0, $s0, 4
    addi $s1, $s1, 1
    j imprimir

exit:
    li $v0, 10
    syscall