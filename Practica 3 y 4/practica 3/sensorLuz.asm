.data
    # Direcciones de hardware simuladas
    LUZ_CONTROL:    .word 0xffff0000
    LUZ_ESTADO:     .word 0xffff0004
    LUZ_DATOS:      .word 0xffff0008

    # Mensajes para la consola
    msg_inicio:     .asciiz "\n--- Iniciando Sensor de Luminosidad ---\n"
    msg_valor:      .asciiz "El valor de luminosidad leido es: "
    msg_error:      .asciiz "Error: Fallo de hardware en el sensor.\n"

.text
.globl main

main:
    #  Imprimir mensaje de inicio
    li $v0, 4          
    la $a0, msg_inicio
    syscall

    #  Ejecutar la lógica del sensor 
    jal InicializarSensorLuz
    jal LeerLuminosidad
    
    #  Verificar si hubo error (basado en $v1) 
    move $s0, $v0       # Guardamos el valor leído en $s0 para que no se pierda
    beq $v1, -1, mostrar_error

    #  Si todo está OK, imprimir el valor numérico
    li $v0, 4           # Imprimir etiqueta "El valor..."
    la $a0, msg_valor
    syscall

    li $v0, 1           # Syscall 1: Imprimir entero (integer)
    move $a0, $s0       # El valor que guardamos en $s0
    syscall

    j fin_programa

mostrar_error:
    li $v0, 4
    la $a0, msg_error
    syscall

fin_programa:
    li $v0, 10          # Salir del programa
    syscall

# PROCEDIMIENTOS 
InicializarSensorLuz:
    lw $t0, LUZ_CONTROL
    li $t1, 0x1         # Escribir 0x1 inicializa el sensor 
    sw $t1, ($t0)
esperar_luz:
    lw $t0, LUZ_ESTADO
    lw $t1, ($t0)
    beq $t1, 1, listo_luz   # 1 -> lectura disponible 
    beq $t1, -1, error_hw   # -1 -> error de hardware 
    j esperar_luz           # 0 -> no listo 
listo_luz:
    jr $ra
error_hw:
    jr $ra

LeerLuminosidad:
    lw $t0, LUZ_ESTADO
    lw $t1, ($t0)
    li $v1, -1
    beq $t1, -1, fin_leer
    lw $t0, LUZ_DATOS       # Registro con la lectura (0-1023) 
    lw $v0, ($t0)
    li $v1, 0               # 0 -> lectura correcta 
fin_leer:
    jr $ra