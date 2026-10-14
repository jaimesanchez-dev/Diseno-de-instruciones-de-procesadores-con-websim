.data
   mu: .byte  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,

               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,

               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
               0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0

.text
show_and_delay:
         # show led matrix
           li   a0, mu
           out  a0, 0x3108
           li   a0, 0x20
           out  a0, 0x3104

         # wait "some time" (looping 20 times)
           li   t0, 0
           li   t1, 20
    bc_10: beq  t0, t1, ec_10
           addi t0, t0, 1
           beq  x0, x0, bc_10
    ec_10: return

 
### (1/2) RISC-V (WITHOUT new extension) ###

vfill_asm: 
           # + arguments:
           #   a0: matrix, a1: neltos, a2: value
           # + algorithm:
           #   for (e=0; e<a1; e++):
           #        matrix[e] <- a2
           li t0 0 #Contador del bucle           
   bucle1: beq t0 a1 fin #Comparar el contador con el numero de elementos
           sb a2 (a0) #a0 es la direccion de incio de la matriz (Guardada en el sp por la anterior instrucción)
           addi a0 a0 1
 					 addi t0 t0 1
           beq x0 x0 bucle1 #Salto al bucle
           
  		fin: 
           return

vadd_asm: 
           # + arguments:
           #   a0: matrix, a1: neltos, a2: value
           # + algorithm:
           #   for (e=0; e<a1; e++):
           #        p <- matrix[e]
           #        p <- p + value
           #        matrix[e] <- p
  	 			 li t0 0 #Contador del bucle 
   bucle2: beq t0 a1 fin2 #Comparar el contador con el numero de elementos
           lb t1 (a0) #Guardar en "P" el valor actual de la matriz
           add t1 t1 a2 #Sumar p + el valor de a2
           sb t1 (a0) #Guardar el nuevo "p" en la matriz
           addi a0 a0 1
           addi t0 t0 1 #Actualizamos el contador
           beq x0 x0 bucle2 #Salto al bucle
           
		fin2:
           return

without_ext: # a0:mu, a1:neltos, a2:color
           addi sp, sp, -8
           sw a0, 0(sp)
           sw a1, 4(sp)
         
           # vadd(mu, 8*24, color)
           call vadd_asm

           # show screen + wait
           call show_and_delay

           # fill(mu+0, 8*24, black)
           lw  a0, 0(sp)
           lw  a1, 4(sp)
           li  a2, 0x00
           call vfill_asm
           
           addi sp, sp, 8
           return

### (2/2) RISC-V (WITH new extension) ###

with_ext: # a0:mu, a1:neltos, a2:color
           addi sp, sp, -8
           sw a0 0(sp)
           sw a1 4(sp)

           # vadd(mu, 8*24, color)
           vadd a1 (a0) a2

           # show screen + wait
           call show_and_delay

           # vfill(mu, 8*24, black)
           lw a0, 0(sp)
           lw a1, 4(sp)
           vfill a1 (a0) 0x00
           
           addi sp, sp, 8
           return
 
main: 
         ##### WITH extension #####
         rdcycle s0

         # verde: mu, 8*24, 0x0a
           li a0, mu
           li a1, 168
           li a2, 0x0a
           call with_ext

         # amarillo: mu+192, 8*24, 0x08
           li   a0, mu
           addi a0, a0, 192
           li   a1, 168
           li   a2, 0x08
           call with_ext

         # rojo: mu+384, 8*24, 0x03
           li   a0, mu
           addi a0, a0, 384
           li   a1, 168
           li   a2, 0x03
           call with_ext

         rdcycle s2
         sub s2, s2, s0

         ##### WITHOUT new extension ##### 
         rdcycle s0

         # verde: mu, 8*24, 0x0a
           li a0 mu
           li a1 168
           li a2 0x0a
           call without_ext

         # amarillo: mu+192, 8*24, 0x08
           li   a0, mu
           addi a0, a0, 192
           li   a1, 168
           li   a2, 0x08
           call without_ext

         # rojo: mu+384, 8*24, 0x03
           li a0, mu
           addi a0, a0, 384
           li a1, 168
           li a2, 0x03
           call without_ext

         rdcycle s1
         sub s1, s1, s0

         # the end
         stop