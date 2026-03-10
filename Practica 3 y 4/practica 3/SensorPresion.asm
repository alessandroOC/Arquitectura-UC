.data
    .align 2
    # Direcciones de hardware 
    PRES_CONTROL:   .word 0xffff0000  # 0x5 inicializa 
    PRES_ESTADO:    .word 0xffff0004  # 1: lectura válida, -1: error 
    PRES_DATOS:     .word 0xffff0008  # Presión medida 

    # Mensajes de Consola
    msg_init:       .asciiz "\n--- Iniciando Sensor de Presion ---\n"
    msg_reintento:  .asciiz "(!) Error detectado. Reiniciando sensor para reintento...\n"
    msg_ok:         .asciiz "Lectura exitosa. Presion: "
    msg_fail:       .asciiz "Error critico: El sensor ha fallado tras el reintento.\n"

.text
.globl main

main:
    #  Mensaje inicial
    li $v0, 4
    la $a0, msg_init
    syscall

    #  Llamar a los procedimientos
    jal InicializarSensorPresion 
    jal LeerPresion 

    # Guardar resultados
    move $s0, $v0       # Valor de presión
    move $s1, $v1       # Código de estado (0 o -1) 

    # 3. Analizar el resultado
    beq $s1, -1, mostrar_fallo

    # Caso Éxito (Estado 0)
    li $v0, 4
    la $a0, msg_ok
    syscall

    li $v0, 1           # Imprimir el valor entero
    move $a0, $s0
    syscall
    j fin

mostrar_fallo:
    li $v0, 4
    la $a0, msg_fail
    syscall

fin:
    li $v0, 10
    syscall

# PROCEDIMIENTOS 

InicializarSensorPresion:
    lw $t0, PRES_CONTROL
    li $t1, 0x5         # Valor 0x5 para inicializar 
    sw $t1, ($t0)
    jr $ra

LeerPresion:
    addi $sp, $sp, -4
    sw $ra, ($sp)
    li $s0, 0           # Contador de reintentos (0 = primer intento) 

bucle_lectura:
    lw $t0, PRES_ESTADO
    lw $t1, ($t0)       # Leer registro de estado 

    beq $t1, 1, exito   # 1 -> Lectura válida 
    beq $t1, 0, bucle_lectura # 0 -> No listo, seguir esperando 

    # Si llega aquí, el estado es -1 (Error) 
    bne $s0, 0, error_final # Si ya reintentamos una vez, fallar 

    # Lógica de reintento 
    li $v0, 4
    la $a0, msg_reintento
    syscall

    jal InicializarSensorPresion # Reiniciar sensor 
    li $s0, 1           # Marcar que ya se usó el reintento 
    j bucle_lectura     # Intentar leer otra vez 

exito:
    lw $t0, PRES_DATOS
    lw $v0, ($t0)       # Cargar presión 
    li $v1, 0           # Estado exitoso 
    j fin_proc

error_final:
    li $v1, -1          # Estado error definitivo 

fin_proc:
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra
