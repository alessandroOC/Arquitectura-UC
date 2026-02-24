.data
	msg: .asciiz "ingrese numero entero positivo: "
	res: .asciiz "(0=par, 1=impar): "
	
.text


main:
	li $v0,4
	la $a0, msg
	syscall
	
	#leer y cargar en $s0
	li $v0,5 
	syscall
	move $s0,$v0
	move $a0, $s0
	jal paridad_recursiva
	
	#guardar resultado e imprimir
	move $s1, $v0
	
	li $v0,4
	la $a0, res
	syscall
	
	li $v0,1
	move $a0, $s1
	syscall
	
	li $v0, 10
	syscall
	
	
paridad_recursiva:
	subi $sp,$sp, 8
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	
	#caaso base, if (n == 0) return 0 
	li $v0,0
	beq $a0, $zero, exit
	
	# 1 - paridad(n - 1)
	subi $a0, $a0,1 # n - 1
	jal paridad_recursiva
	
	# Al volver, $v0 trae paridad(n-1)
   	li $t0, 1
    	sub $v0, $t0, $v0   # $v0 = 1 - $v0
exit:

	lw $a0, 0($sp)      
   	lw $ra, 4($sp)      
    	addi $sp, $sp, 8   
    	jr $ra

