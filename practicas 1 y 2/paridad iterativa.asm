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
	
paridad_iterativa:
	li $t0,0 #result
	li $t1,0 #i
for:
	beq $t1, $s0, imprimir #si i= numero, salir
	li $t2 ,1
	sub $t0, $t2, $t0 # result= 1- result, 1-0=1 impar, 1-1=par
	addi $t1, $t1,1 #i++
	j for
	
imprimir:
	li $v0,4
	la $a0, res
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 10
	syscall


	
	