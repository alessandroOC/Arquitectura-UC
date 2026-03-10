
# El programa imprime el estado inicial una sola vez y espera la interrupción.

.data
msg_verde:    .asciiz "\n--- SISTEMA INICIADO ---\nSemáforo en verde, esperando pulsador (tecla 's').\n" 
msg_cambio:   .asciiz "\nPulsador activado: en 20 segundos, el semáforo cambiará a amarillo.\n" 
msg_amarillo: .asciiz "\nSemáforo en amarillo, en 10 segundos, semáforo en rojo.\n"
msg_rojo:     .asciiz "\nSemáforo en rojo, en 30 segundos, semáforo en verde.\n" 

.text
.globl main

main:
    #  Configuración de Interrupciones de Teclado (Hardware) [cite: 3, 38]
    li $t0, 0xffff0000       # Dirección del Receiver Control
    lw $t1, ($t0)
    ori $t1, $t1, 2          # Habilitar bit 1 (Interrupt Enable) [cite: 37, 38]
    sw $t1, ($t0)

    #  Configuración del Registro de Estado (Status Register) del CPU [cite: 26, 40]
    mfc0 $t0, $12            # Leer registro Status
    ori $t0, $t0, 0x0801     # Habilitar interrupciones globales (bit 0) y teclado (bit 11) [cite: 40]
    mtc0 $t0, $12

    #  Imprimir estado inicial UNA SOLA VEZ 
    li $v0, 4
    la $a0, msg_verde
    syscall

idle_loop:
    # El programa se queda aquí "haciendo nada" de forma eficiente.
    # No imprime nada. Solo espera a que el hardware dispare la interrupción. 
    nop
    j idle_loop

# RUTINA DE SERVICIO DE INTERRUPCIÓN (ISR)
.ktext 0x80000180
    # Guardar contexto mínimo para no perder datos del programa principal 
    .set noat
    move $k0, $at
    .set at

    # Verificar la causa (registro Cause) 
    mfc0 $k1, $13
    andi $k1, $k1, 0x00000100 # ¿Fue una interrupción de hardware externa?
    beq $k1, $zero, fin_isr

    # Leer el carácter del Receiver Data para limpiar la interrupción 
    li $t0, 0xffff0004
    lw $t1, ($t0)
    
    # Comprobar si la tecla pulsada es 's' (ASCII 115) 
    li $t2, 115
    bne $t1, $t2, fin_isr

    # -Lógica del Semáforo 
    
    # Cambio a Amarillo
    li $v0, 4
    la $a0, msg_cambio
    syscall
    li $v0, 32         # Syscall Sleep
    li $a0, 20000      # 20 segundos 
    syscall

    # Amarillo
    li $v0, 4
    la $a0, msg_amarillo
    syscall
    li $v0, 32
    li $a0, 10000      # 10 segundos 
    syscall

    # Rojo
    li $v0, 4
    la $a0, msg_rojo
    syscall
    li $v0, 32
    li $a0, 30000      # 30 segundos 
    syscall

    # Regreso a Verde 
    li $v0, 4
    la $a0, msg_verde
    syscall

fin_isr:
    # Restaurar contexto y regresar al punto exacto donde estaba el programa 
    .set noat
    move $at, $k0
    .set at
    eret               # Retorna a la dirección guardada en el EPC 