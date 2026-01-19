.data
	array: .space 20
	mensaje: .asciiz "ingrese numero: "
	esp: .asciiz " "
.text
main:
	la $t0, array
	li $t1, 0 #i
	li $t2, 5
	li $t3,0 #j
	

llenar:
	beq $t1,$t2,reset
	li $v0,4
	la $a0,mensaje
	syscall
	
	li $v0,5
	syscall
	
	sw $v0, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 1
j llenar

reset:
	la $t0,array
	li $t1,0
	

for_externo:
	addi $t1,$t1,1
	bgt $t1,$t2,reset2
	
	la $t0, array
	li $t3,0
	sub $t4, $t2, $t1
	
	for_interno:
		beq $t3,$t4,for_externo
		lw $t5,0($t0)
		lw $t6,4($t0)
		bgt $t6,$t5, Nswap
		
		sw $t6,0($t0)
		sw $t5,4($t0)
		
		
	Nswap:
		addi $t3,$t3,1
		addi $t0,$t0,4
	j for_interno
	
reset2:
	la $t0,array
	li $t1,0
	
	
mostrar:
	beq $t1,$t2, exit
	lw $a0, 0($t0)
	li $v0,1
	syscall
	
	li $v0,4
	la $a0, esp
	syscall
	
	addi $t0,$t0,4
	addi $t1,$t1,1
j mostrar

exit:
	li $v0,10
	syscall
