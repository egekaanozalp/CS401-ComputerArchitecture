.data

IV: .word 0x3412, 0x7856, 0xBC9A, 0xF0DE
K: .word 0x2301, 0x6745, 0xAB89, 0xEFCD, 0xDCFE, 0x98BA, 0x5476, 0x1032
R: .space 32 #Space for R0 to R7



#Large Tables Method
S: .byte 0x2, 0xF, 0xC, 0x1, 0x5, 0x6, 0xA, 0xD, 0xE, 0x8, 0x3, 0x4, 0x0, 0xB, 0x9, 0x7
   ,0xF, 0x4, 0x5, 0x8, 0x9, 0x7, 0x2, 0x1, 0xA, 0x3, 0x0, 0xE, 0x6, 0xC, 0xD, 0xB
   ,0x4, 0xA, 0x1, 0x6, 0x8, 0xF, 0x7, 0xC, 0x3, 0x0, 0xE, 0xD, 0x5, 0x9, 0xB, 0x2
   ,0x7, 0xC, 0xE, 0x9, 0x2, 0x1, 0x5, 0xF, 0xB, 0x6, 0xD, 0x0, 0x4, 0x8, 0xA, 0x3
              
# P-Box (Permutation Table)
pbox: .byte 7, 6, 4, 2, 3, 0, 5, 1
   
done_msg_ffunction: .asciiz "Done computing F(X):\n"
done_msg_wfunction: .asciiz "Done computing W(X,A,B):\n"
done_msg_initialization: .asciiz "Done initializing of the State Vector:\n"
newline: .asciiz "\n"

.text
.globl main

main:
    
    li $t0 0xBBAA
    jal ffunction
    
    li $v0, 4           
    la $a0, done_msg_ffunction   
    syscall            

    move $a0, $t0       
    li $v0, 34          
    syscall
    
    li $v0, 4           
    la $a0, newline
    syscall   
    
    li $s0, 0xBBAA #X
    li $s1, 0xCCCC #A
    li $s2, 0xDDDD #B
    
    jal wfunction
 
    li $v0, 4           
    la $a0, done_msg_wfunction   
    syscall             

    move $a0, $t0       
    li $v0, 34          
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall   
    
    jal initilization
    
    li $v0, 10          
    syscall

initilization:
    
    addi $sp, $sp, -28
    sw $s3, 0($sp)
    sw $s4, 4($sp)
    sw $s5, 8($sp)
    sw $s0, 12($sp)
    sw $s1, 16($sp)
    sw $s2, 20($sp)
    sw $s6, 24($sp)
    
    #Load initial vector
    la $s3, IV
    la $s4, R
    la $s5, K
    
    li $t3, 0 #i
    li $t4, 4
    
loop_init_r:
   
    beq $t3, 8, end_loop_init_r
    divu $t3, $t4
    mfhi $t5 #Get the remainder (i%4)
    
    sll $t5, $t5, 2 #Mult with four
    add $t5, $t5, $s3
    
    lw $t6, 0($t5) #Get the i mod 4th element of IV
    
    sll $t7, $t3, 2 #Mult with four
    add $t7, $t7, $s4
    
    sw $t6, 0($t7)
    
    addi $t3, $t3, 1
    
    j loop_init_r

end_loop_init_r:
    
    li $s6, 0 #i
    
loop_init_w:
    
    beq $s6, 4, end_loop_init_w
    
    lw $t1, 0($s4) #R[0]
    add $t1, $t1, $s6
    andi $t1, $t1, 0xFFFF #Get the lower 16-bits
   
    move $s0, $t1 #R[0] + i mod 2^16
    lw $s1, 4($s5) #K[1]
    lw $s2, 12($s5) #K[3]
    
    jal wfunction
    
    addi $sp, $sp, -16
    sw $t0, 0($sp) #Store t0
    
    lw $t1, 4($s4) #R[1]
    add $t1, $t1, $t0 #R[1] + t0
    andi $t1, $t1, 0xFFFF
    
    move $s0, $t1 #R[1] + t0 mod 2^16
    lw $s1, 20($s5) #K[5]
    lw $s2, 28($s5) #K[7]
    
    jal wfunction
    
    sw $t0, 4($sp) #Store t1
    
    lw $t1, 8($s4) #R[2]
    add $t1, $t1, $t0 #R[2] + t1
    andi $t1, $t1, 0xFFFF
    
    move $s0, $t1 #R[2] + t1 mod 2^16
    lw $s1, 0($s5) #K[0]
    lw $s2, 8($s5) #K[2]
    
    jal wfunction
    
    sw $t0, 8($sp) #Store t2
    
    lw  $t1, 12($s4) #R[3]
    add $t1, $t1, $t0 #R[3] + t2
    andi $t1, $t1, 0xFFFF
    
    move $s0, $t1 #R[3] + t2 mod 2^16
    lw $s1, 16($s5) #K[4]
    lw $s2, 24($s5) #K[6]
    
    jal wfunction
    
    sw $t0, 12($sp) #Store t3
    
    lw $t1, 0($s4) #R[0]
    add $t1, $t1, $t0 #R[0] + t3
    andi $t1, $t1, 0xFFFF #R[0] + t3 mod 2^16
    
    #Circular Shift Left 7
    andi $t2, $t1, 0x1FF #0000000111111111 First 9 digits for the left circular shift
    sll $t2, $t2, 7
    andi $t3, $t1, 0xFE00 #1111111000000000 Last 7 digits for the left circular shift
    srl $t3, $t3, 9
    
    or $t0, $t3, $t2  
    sw $t0, 0($s4) #Save to R[0]
    
    lw $t1, 4($s4) #R[1]
    lw $t4, 0($sp) #t0
    
    add $t1, $t1, $t4 #R[1] + t0
    andi $t1, $t1, 0xFFFF #R[1] + t0 mod 2^16   
    
    #Right Circular Shift Right 4
    andi $t2, $t1, 0xF #0000000000001111 First 4 digits for the right circular shift
    sll $t2, $t2, 12
    andi $t3, $t1, 0xFFF0 #1111111111110000 Last 12 digits for the right circular shift
    srl $t3, $t3, 4  
    
    or $t0, $t3, $t2  
    sw $t0, 4($s4) #Save to R[1]
    
    lw $t1, 8($s4) #R[2]
    lw $t4, 4($sp) #t1
    
    add $t1, $t1, $t4 #R[2] + t1
    andi $t1, $t1, 0xFFFF #R[2] + t1 mod 2^16
    
    #Circular Shift Left 2
    andi $t2, $t1, 0x3FFF #0011111111111111 First 14 digits for the left circular shift
    sll $t2, $t2, 2
    andi $t3, $t1, 0xC000 #1100000000000000 Last 2 digits for the left circular shift
    srl $t3, $t3, 14
    
    or $t0, $t3, $t2  
    sw $t0, 8($s4) #Save to R[2]
    
    lw $t1, 12($s4) #R[3]
    lw $t4, 8($sp) #t2
    
    add $t1, $t1, $t4 #R[3] + t2
    andi $t1, $t1, 0xFFFF #R[3] + t2 mod 2^16
    
    #Right Circular Shift Right 9
    andi $t2, $t1, 0x1FF #0000000111111111 First 9 digits for the right circular shift
    sll $t2, $t2, 7
    andi $t3, $t1, 0xFE00 #1111111000000000 Last 7 digits for the right circular shift
    srl $t3, $t3, 9   
    
    or $t0, $t3, $t2  
    sw $t0, 12($s4) #Save to R[3]
    
    addi $sp, $sp, 16 #No more use for t0 to t3
    
    lw $t0, 16($s4) #R[4]
    lw $t1, 12($s4) #R[3]
    
    xor $t0, $t0, $t1
    
    sw $t0, 16($s4) #Save to R[4]
    
    lw $t0, 20($s4) #R[5]
    lw $t1, 4($s4) #R[1]
    
    xor $t0, $t0, $t1
    
    sw $t0, 20($s4) #Save to R[5]
    
    lw $t0, 24($s4) #R[6]
    lw $t1, 8($s4) #R[2]
    
    xor $t0, $t0, $t1
    
    sw $t0, 24($s4) #Save to R[6]
    
    lw $t0, 28($s4) #R[7]
    lw $t1, 0($s4) #R[0]
    
    xor $t0, $t0, $t1
    
    sw $t0, 28($s4) #Save to R[7]
    
    addi $s6, $s6, 1
    
    j loop_init_w
    
end_loop_init_w:
    
    addi $sp, $sp, 28
    lw $s3, 0($sp)
    lw $s4, 4($sp)
    lw $s5, 8($sp)
    lw $s0, 12($sp)
    lw $s1, 16($sp)
    lw $s2, 20($sp)
    lw $s6, 24($sp)

    li $v0, 4
    la $a0, done_msg_initialization
    syscall

    la $t0, R
    li $t1, 0       
    
print_R_loop:
    beq $t1, 8, end_print_R_loop
    
    lw $a0, 0($t0)
    li $v0, 34      
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    addi $t0, $t0, 4
    addi $t1, $t1, 1
    
    j print_R_loop

end_print_R_loop:
    li $v0, 10  
    syscall
    
wfunction: 

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    xor $t0, $s0, $s1 #xor X and A
    jal ffunction
    
    xor $t0, $t0, $s2 #xor output and B
    jal ffunction 
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

ffunction: #takes $t0 input outputs $t0

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal extract
    sll $t4, $t4, 4
    or $t0, $t4, $t3 #x0||x1
    
    jal permutation_func #result at $t9
    
    sll $t2, $t2, 12
    sll $t1, $t1, 8
    or $t0, $t2, $t1
    or $t0, $t9, $t0 #input to the calculateS_Large is at $t0 (value to be extracted)
    
    jal extract
    jal calculateS_Large #Output at $t0 and input for linear_func
   
    jal linear_func
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
         
extract:
    andi $t1, $t0, 0xF #Extract x3
    srl $t0, $t0, 4 #Shift input right by 4 bits to extract x2
    andi $t2, $t0, 0xF #Extract x2
    srl $t0, $t0, 4 #Shift input right by 4 bits to extract x1
    andi $t3, $t0, 0xF #Extract x1
    srl $t0, $t0, 4 #Shift input right by 4 bits to extract x0
    andi $t4, $t0, 0xF #Extract x0
    
    jr $ra

calculateS_Large:

    la $t5, S #Base address of S
    
    addu $t6, $t5, $t4 
    lb $t6, 0($t6) #Load S0[x0] 
    sll $t6, $t6, 12
    
    addi $t5, $t5, 16 #Move to S1
    addu $t7, $t5, $t3
    lb $t7, 0($t7) #Load S1[X1]
    sll $t7, $t7, 8 
    
    addi $t5, $t5, 16 #Move to S2
    addu $t8, $t5, $t2
    lb $t8, 0($t8) #Load S2[X2]
    sll $t8, $t8, 4
    
    addi $t5, $t5, 16 #Move to S1
    addu $t9, $t5, $t1
    lb $t9, 0($t9) #Load S3[X3]
    
    #Concatenate Operation  
    or $t6, $t6, $t7
    or $t6, $t6, $t8
    or $t6, $t6, $t9
    
    move $t0, $t6
    
    jr $ra
    
linear_func:
    
    #Circular Shift Left
    andi $t1, $t0, 0x3FF #0000001111111111 First 10 digits for the left circular shift
    sll $t1, $t1, 6
    andi $t2, $t0, 0xFC00 #1111110000000000 Last 6 digits for the left circular shift
    srl $t2, $t2, 10
    
    #Concatenate Operation  
    or $t1, $t1, $t2
    
    andi $t3, $t0, 0xFFC0 #1111111111000000 Last 10 digits for the right circular shift
    srl $t3, $t3, 6
    andi $t4, $t0, 0x3F #0000000000111111 First 6 digits for the right circular shift
    sll $t4, $t4, 10
    
    #Concatenate Operation  
    or $t3, $t3, $t4
    
    #XOR Operations
    xor $t0, $t0, $t1
    xor $t0, $t0, $t3
    
    jr $ra
    
permutation_func:
    
    li $t9, 0
    la $t8, pbox  #Load the address for the P-box
    
    li $t3, 0
    li $t7, 7

permutation_loop:

    beq $t3, 8, permutation_end
    
    lb $t4, 0($t8) #Load the i-th index from the p-box
    move $t5, $t0
    
    li $t6, 1 #Create mask for the retrieval of mapped index
    sub $t4, $t7, $t4 #Shift amount for the mask
    sllv $t6, $t6, $t4
    and $t5, $t5, $t6 #Get the mapped index of the input
    srlv $t5, $t5, $t4 #Get the bit to the rigt most signifcant position
    
    sub $t6, $t7, $t3 #Shift amount for the new position of the bit
    sllv $t5, $t5, $t6
    
    or $t9, $t9, $t5 #Add to the result
    
    addi $t3, $t3, 1
    addi $t8, $t8, 1
    j permutation_loop 
         
permutation_end:  

    jr $ra
