.data
    mensaje: .asciiz "ingrese el numero: "
    esp:     .asciiz " "
    .align 2
    array:   .space 20
    val:     .asciiz "\ningrese el valor que busca: "
    res:     .asciiz "el valor se encuentra en el indice: "
    N_res:   .asciiz "el valor no se encuentra."

.text
main:
    la $t0, array
    li $t1, 0 
    li $t2, 5 

llenar:
    beq $t1, $t2, reset
    li $v0, 4
    la $a0, mensaje
    syscall
    
    li $v0, 5
    syscall
    sw $v0, 0($t0)
    
    addi $t0, $t0, 4
    addi $t1, $t1, 1
    j llenar

reset:
    li $t1, 0              
    li $t2, 4              

valor:
    li $v0, 4
    la $a0, val
    syscall
    li $v0, 5
    syscall
    move $s0, $v0         

while:
 
    blt $t2, $t1, N_encontrado 
    
    add $t3, $t1, $t2       
    srl $t4, $t3, 1         
    mul $t6,$t4,4   
    la $t0, array           
    add $t0, $t0, $t6      
    lw $t5, 0($t0)          
    
    beq $s0, $t5, encontrado
    blt $s0, $t5, menos
    
    addi $t1, $t4, 1       
    j while

menos:
    subi $t2, $t4, 1       
    j while

N_encontrado:
    li $v0, 4
    la $a0, N_res
    syscall
    j exit

encontrado: 
    li $v0, 4
    la $a0, res
    syscall
    
    li $v0, 1
    addi $t4, $t4,1
    move $a0, $t4           
    syscall

exit:
    li $v0, 10
    syscall