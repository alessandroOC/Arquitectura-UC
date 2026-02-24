.data
	array: .word 10, 80, 30, 90, 40, 50, 70
	size: .word 7
	space: .asciiz " "
.text
.globl main
main:
	la $a0, array
	li $a1, 0 #low
	lw $t0, size
	subi $a2, $t0, 1 #high
	jal quick
	
	li $s0, 0
	li $s1, 7
	la $t0,array
	
print:
	beq $s0, $s1, exit
	lw $a0, 0($t0)
	li $v0,1
	syscall
	li $v0,4
	la $a0, space
	syscall
	addi $t0, $t0,4
	addi $s0, $s0,1
	j print
	
exit:
	li $v0,10
	syscall
	

quick:
	subi $sp, $sp, 16
	sw $ra, 0($sp)
	sw $a1, 4($sp)#low
	sw $a2, 8($sp)#high
	
	slt $t0, $a1, $a2 #if low<high
	beq $t0, $zero, endQ
	
	jal partition
	#guardar el pivot retornado en $v0 en el stack
	sw $v0,12($sp)
	
	# llamada izquierda: quick(arr, low, pivot - 1)
	lw $v0,12($sp) # recuperar low original
	lw $a1, 4($sp) #recuperar pivot
	subi $a2, $v0, 1 # high= pivt -1
	jal quick
	
	# llamada derecha: quick(arr, pivot + 1, high)
	lw $v0, 12($sp) #recuperar pivot
	addi $a1, $v0, 1 #low= pivot +1
	lw $a2, 8($sp) #recuperar high orig
	jal quick

endQ:
	lw $ra, 0($sp)
	addi $sp, $sp,16
	jr $ra

partition:
	mul $t0, $a2,4 #direccion arr{high}
	add $t0, $t0, $a0
	lw $t0,0($t0) #t0= arr{high}
	
	subi $t1, $a1, 1 #t1 =i
	move $t2, $a1 #t2= j
	
partition_loop:
	slt $t3,$t2,$a2 #j<high
	beq $t3,$zero, P_end
	
	mul $t4, $t2, 4 #indice arr{j}
	add $t4, $t4, $a0
	lw $t5, 0($t4)  #t5=arrj
	
	slt $t3,$t5,$t0
	beq $t3, $zero, next_j
	
	addi $t1, $t1,1 #i++
	# swap arr{i} y arr{j}
	mul $t7, $t1, 4
	add $t7, $a0, $t7
	lw $t8, 0($t7) #temp = arr{i}
	sw $t5, 0($t7) #arr{i}= arr{j}
	sw $t8, 0($t4) #arr{j}= temp

next_j:
	addi $t2, $t2,1
	j partition_loop

P_end:
	#swap arr{i+1] y arr{hihg} (pivote)
	addi $t6, $t1,1
	mul $t7, $t6, 4
	add $t7, $t7, $a0
	lw $t8, 0($t7) 	#temp arr[i+1]
	
	mul $t4, $a2,4
	add $t4, $t4, $a0
	lw $t9, 0($t4)#arr{high}
	
	sw  $t9,0($t7) #arr[i+1]= arr[high]
	sw $t8, 0($t4) #arr[high]=temp
	
	move $v0,$t6
	jr $ra
