
.data
    .align 2
    buffer:         .space 100       # Espacio para 100 caracteres
    indice:         .word 0          # Puntero al buffer circular
    limite:         .word 100
    msg_inicio:     .asciiz "Esperando 20s... Escribe en el simulador de teclado (SOLO MAYUSCULAS).\n"
    msg_fin:        .asciiz "\n--- Contenido del Buffer despues de 20s ---\n"

.text
.globl main

main:
    #  Habilitar Interrupciones en el Dispositivo (Teclado)
    li $t0, 0xffff0000       # Receiver Control
    lw $t1, ($t0)
    ori $t1, $t1, 0x02       # Bit 1 = Interrupt Enable
    sw $t1, ($t0)

    # Habilitar Interrupciones en el Procesador (Registro Status)
    mfc0 $t0, $12            # Leer registro Status del CP0
    ori  $t0, $t0, 0x0801    # Bit 0 (IE) y Bit 11 (Keyboard Mask en MARS)
    mtc0 $t0, $12            # Escribir de vuelta al CP0

    # Imprimir mensaje de inicio
    li $v0, 4
    la $a0, msg_inicio
    syscall

    #  Bucle de espera de "20 segundos" (Simulado)
    li $s0, 0
espera:
    addi $s0, $s0, 1
    # Pausa para que no vuele el contador (aprox 20s dependiendo de la velocidad)
    li $t2, 0
delay_loop:
    addi $t2, $t2, 1
    blt $t2, 2000, delay_loop
    
    blt $s0, 200, espera     # Bucle principal "infinito" hasta que acabe el tiempo

    #  Imprimir contenido del buffer
    li $v0, 4
    la $a0, msg_fin
    syscall
    
    li $v0, 4
    la $a0, buffer
    syscall

    # Finalizar programa
    li $v0, 10
    syscall


.ktext 0x80000180            # Direccion fija de excepciones en MIPS
    
    # GUARDAR CONTEXTO 
    .set noat
    move $k1, $at            # Guardar registro reservado para el ensamblador
    .set at
    sw $v0, k_v0             # Guardar registros que usaremos
    sw $a0, k_a0
    sw $t0, k_t0

    #  Identificar la causa (Registro Cause del CP0)
    mfc0 $k0, $13            # Leer Cause
    andi $k0, $k0, 0x003c    # Aislar bits de codigo de excepcion (0 = Interrupcion)
    bne  $k0, $zero, fin_handler

    #  Leer el caracter del teclado
    li $t0, 0xffff0004       # Receiver Data
    lw $a0, ($t0)

    #  FILTRO: Solo mayusculas (A-Z)
    blt $a0, 65, fin_handler # ASCII < 65 ('A')
    bgt $a0, 90, fin_handler # ASCII > 90 ('Z')

    # Almacenar en Buffer Circular
    lw $t0, indice
    la $t1, buffer
    add $t1, $t1, $t0        # Direccion buffer + indice
    sb $a0, ($t1)            # Guardar caracter
    
    addi $t0, $t0, 1         # Incrementar indice
    lw $t2, limite
    blt $t0, $t2, guardar_ind
    li $t0, 0                # Reiniciar si llega al final (Circular)
guardar_ind:
    sw $t0, indice

fin_handler:
    # RESTAURAR CONTEXTO 
    lw $t0, k_t0
    lw $a0, k_a0
    lw $v0, k_v0
    .set noat
    move $at, $k1
    .set at
    
    eret                     # Retornar al programa usando EPC

.kdata
    k_v0: .word 0
    k_a0: .word 0
    k_t0: .word 0
