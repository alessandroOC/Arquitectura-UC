.data
    .align 2
    # Direcciones solicitadas 
    TEN_CONTROL:    .word 0xffff0000  # 1: Inicia medición
    TEN_ESTADO:     .word 0xffff0004  # 0: midiendo, 1: listo
    TEN_SISTOL:     .word 0xffff0008  # Resultado Sistólica
    TEN_DIASTOL:    .word 0xffff000c  # Resultado Diastólica (siguiente palabra)

    # Mensajes de Consola
    msg_ten_ini:    .asciiz "\n--- Iniciando Medicion de Tension Arterial ---\n"
    msg_espera:     .asciiz "Midiendo... por favor espere.\n"
    msg_res_sis:    .asciiz "Resultado Sistolica: "
    msg_res_dia:    .asciiz "\nResultado Diastolica: "
    msg_unidad:     .asciiz " mmHg"

.text
.globl main

main:
    #  Mensaje inicial
    li $v0, 4
    la $a0, msg_ten_ini
    syscall

    #  Llamar al controlador
    jal controlador_tension

    # Guardar resultados (vienen en $v0 y $v1)
    move $s0, $v0       # Sistólica
    move $s1, $v1       # Diastólica

    #  Imprimir resultados
    li $v0, 4
    la $a0, msg_res_sis
    syscall
    li $v0, 1           # Imprimir entero (Sistólica)
    move $a0, $s0
    syscall
    li $v0, 4
    la $a0, msg_unidad
    syscall

    li $v0, 4
    la $a0, msg_res_dia
    syscall
    li $v0, 1           # Imprimir entero (Diastólica)
    move $a0, $s1
    syscall
    li $v0, 4
    la $a0, msg_unidad
    syscall

    # Finalizar
    li $v0, 10
    syscall

#  PROCEDIMIENTO CONTROLADOR 
controlador_tension:
    # Iniciar medición
    lw   $t0, TEN_CONTROL
    li   $t1, 1
    sw   $t1, ($t0) 

    # Mensaje de espera
    li   $v0, 4
    la   $a0, msg_espera
    syscall

esperar_tension:
    lw   $t0, TEN_ESTADO
    lw   $t1, ($t0) 
    bne  $t1, 1, esperar_tension # Mientras sea 0, seguir esperando 

    # Recuperar resultados
    lw   $t0, TEN_SISTOL
    lw   $v0, ($t0)          # Sistólica en $v0 
    
    lw   $t0, TEN_DIASTOL
    lw   $v1, ($t0)          # Diastólica en $v1 

    jr   $ra