# This program results from the compilation of quicksort.c
# Author: A. G. Medrano-Chávez

# global array a
    .data
array:  .word 706, -200, -19, 103, 122, -851, 529, 91, -264, -727
# array[9] =  706   2C2
# array[8] =  529   211
# array[7] =  122   7A
# array[6] =  103   67
# array[5] =  91    5B
# array[4] = -19    FFFFFFFFED
# array[3] = -200   FFFFFFFF38
# array[2] = -264   FFFFFFFEF8
# array[1] = -727   FFFFFFFD29
# array[0] = -851   FFFFFFFCAD

# swap function
# kind: leaf function
# convention: a0 <-> *a, a1 <-> *b, t0 <-> temp, tp holds auxiliar values
# frame size: 0 bytes
# access-memory policy: load and store when needed
# returned value: none
    .text
    .globl swap
swap:
    lw       t0, 0(a0)          # temp = *a
    lw       tp, 0(a1)          # temp = *b
    sw       tp, 0(a0)          # *a = *b
    sw       t0, 0(a1)          # *b = temp
    jr       ra                 # returns control to caller

# quicksort function
# kind: recursive function
# convention: a0 <-> *a, a1 <-> len, tp and t0 hold auxiliar values
# frame size: 48 bytes
#     - 4 words to back ra and fp up
#     - 4 words to back local variables up
#     div <-> -16, pivot <-> -20, i <-> -24, j <-> -28 
#     - 4 words to back a1 and a0 up
#     a1 <-> -32, a0 <-> -36
# access-memory policy: load when needed store after update
# returne value: none
    .globl quicksort
quicksort:
    addi     sp, sp, -48        # updates sp
    sw       ra, 48(sp)         # backs ra up
    sw       fp, 44(sp)         # backs fp up
    addi     fp, sp, 48         # updates fp
    li       tp, 2              # tp = 2
    bge      a1, tp, L1         # jumps if a1 >= 2 to L1
    lw       ra, 48(sp)         # restores ra
    lw       fp, 44(sp)         # restores fp
    addi     sp, sp, 48         # frees quicksort's frame
    jr       ra                 # returns control caller
L1: srli     tp, a1, 1          # tp = a1 / 2
    slli     tp, tp, 2          # tp = 4*tp
    add      tp, a0, tp         # tp = a0 + 4*tp
    lw       tp, 0(tp)          # tp = a[len / 2]
    sw       tp, -20(fp)        # pivot = a[len / 2]
    li       tp, 0              # tp = 0
    sw       tp, -24(fp)        # i = 0
    addi     tp, a1, -1         # tp = len - 1
    sw       tp, -28(fp)        # j = len - 1
L3: lw       tp, -24(fp)        # tp = i
    slli     tp, tp, 2          # tp = 4*tp
    add      tp, a0, tp         # tp = a0 + 4*tp
    lw       tp, 0(tp)          # tp = a[i]
    lw       t0, -20(fp)        # t0 = pivot
    bge      tp, t0, L4         # jumps to L4 if a[i] >= pivot
    lw       tp, -24(fp)        # tp = i
    addi     tp, tp, 1          # tp = tp + 1
    sw       tp, -24(fp)        # i = i + 1
    j        L3                 # jumps to L3
L4: lw       tp, -28(fp)        # tp = j
    slli     tp, tp, 2          # tp = 4*tp
    add      tp, a0, tp         # tp = a0 + 4*tp
    lw       tp, 0(tp)          # tp = a[j]
    lw       t0, -20(fp)        # t0 = pivot
    ble      tp, t0, L5         # jumps if a[j] <= pivot
    lw       tp, -28(fp)        # tp = j
    addi     tp, tp, -1         # tp = tp - 1
    sw       tp, -28(fp)        # j = j - 1
    j        L4                 # jumps to L3
L5: lw       tp, -24(fp)        # tp = i
    sw       tp, -16(fp)        # div = i
    lw       tp, -24(fp)        # tp = i
    lw       t0, -28(fp)        # t0 = j
    blt      tp, t0, L6         # jumps to L6 if i < j
    j        L7                 # breaks for loop
    # calls swap function
L6: sw       a1, -32(fp)        # backs a1 up
    sw       a0, -36(fp)        # backs a0 up
    lw       tp, -28(fp)        # tp = j
    slli     tp, tp, 2          # tp = 4*tp
    lw       t0, -36(fp)        # t0 = addr(a)
    add      a1, t0, tp         # a1 = addr(a)+ 4*j
    lw       tp, -24(fp)        # tp = i
    slli     tp, tp, 2          # tp = 4*tp
    lw       t0, -36(fp)        # t0 = addr(a)
    add      a0, t0, tp         # addr(a) + 4*i
    jal      swap               # calls swap
    lw       a1, -32(fp)        # restores a1
    lw       a0, -36(fp)        # restores a0
    lw       tp, -24(fp)        # tp = i
    addi     tp, tp, 1          # tp = tp + 1
    sw       tp, -24(fp)        # i = i + 1
    lw       tp, -28(fp)        # tp = j
    addi     tp, tp, -1         # tp = tp - 1
    sw       tp, -28(fp)        # j = j - 1
    j        L3                 # jumps to L3
    # calls quicksort function
L7: sw       a1, -32(fp)        # backs a1 up
    sw       a0, -36(fp)        # backs a0 up
    lw       a1, -16(fp)        # a1 = div
    lw       a0, -36(fp)        # a0 = addr(a)
    jal      quicksort          # calls quicksort
    lw       a1, -32(fp)        # restores a1
    lw       a0, -36(fp)        # restores a0
    # calls quicksort function
    sw       a1, -32(fp)        # backs a1 up
    sw       a0, -36(fp)        # backs a0 up
    lw       tp, -16(fp)        # tp = div
    lw       t0, -32(fp)        # t0 = len
    sub      a1, t0, tp         # a1 = len - div
    lw       tp, -16(fp)        # tp = div
    slli     tp, tp, 2          # tp = 4*tp
    lw       t0, -36(fp)        # t0 = addr(a)
    add      a0, t0, tp         # a0 = addr(a) + div
    jal      quicksort          # calls quicksort
    lw       a1, -32(fp)        # restores a1
    lw       a0, -36(fp)        # restores a0
L2: lw       ra, 48(sp)         # restores ra
    lw       fp, 44(sp)         # restores fp
    addi     sp, sp, 48         # frees quicksort's frame
    jr       ra                 # returns control caller

# main function
# kind: nested function
# convention: tp holds auxiliar values
# frame size: 16 bytes
#     - 4 words to back ra and fp up
# access-memory policy: load when needed store after update
# returne value: a0 holds 0
    .globl main
main:
    addi     sp, sp, -16        # updates sp
    sw       ra, 16(sp)         # backs ra up
    sw       fp, 12(sp)         # backs fp up
    addi     fp, sp, 16         # updates fp
    # call function
    li       a1, 10             # a1 = 8
    mv       a0, gp             # a0 = *a
    jal      quicksort          # calls quicksort
    # return 0
    li       a0, 0              # a0 = 0
    lw       ra, 16(sp)         # restores ra
    lw       fp, 12(sp)         # restores fp
    addi     sp, sp, 16         # frees main's frame
    jr       ra                 # returns control to OS