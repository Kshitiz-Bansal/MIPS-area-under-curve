# TO DO       - test cases
#             - handle OVERFLOW // done //
#             - handle wrong input // done
#             - change input method // done
#             - better prompts
#             - RAISE EXCEPTIONS???

# COL216: Assignment 1
# Code of: Kshitiz Bansal
#           2019CS50438


    .data

prompt1: .asciiz "Enter the number of points: "
promptx: .asciiz "Enter x: "
prompty: .asciiz "Enter y: "
prompt_overflow: .asciiz "Values overflowed. Execution terminated. "
prompt_wrong_in: .asciiz "ERROR: Points should be ordered by x coordinate. Executon terminated. "
prompt_n_wrong: .asciiz "ERROR: n should be >= 2. Execution terminated. "
debug1: .asciiz "here1"
NT: .asciiz "Normal Termination."
newline: .asciiz "\n"

ans: .double 0.00 # stores final answer
half: .double 0.50
zero: .double 0.00


    .text

main:

# number of points taken as input from user
    li $v0, 4
    la $a0, prompt1
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

# check if n > 1
    li $t1, 1
    bgt $t0, $t1, not_zero

# n <= 1 // return 0 // SHOW ERROR AND TERMINATE
    # li $t0, 0
    # li $v0, 1
    # la $a0, ($t0)
    # syscall

    li $v0, 4
    la $a0, prompt_n_wrong
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 10
    syscall
# n >= 2
not_zero:
# taking in x coordinate of the first point
# (done outside loop because not storing all the points, problem broken down into pair of points)
# refer to pdf for more details
    li $v0, 4
    la $a0, promptx
    syscall

    li $v0, 5
    syscall
    move $t6, $v0 # prev x

# taking in y coordinate of the first point
    li $v0, 4
    la $a0, prompty
    syscall

    li $v0, 5
    syscall
    move $t7, $v0 # prev y

    li $t2, 1 # LOOP INDEX

# --- DND ----- t0, t2, t6, t7, t8, t9
main_loop:

# taking x coordinate
    li $v0, 4
    la $a0, promptx
    syscall

    li $v0, 5
    syscall
    move $t8, $v0 # curr x

# --- INPUT SHOULD BE SORTED
    bgt $t6, $t8, wrong_input
# storing curr x, will be needed in next iteration of this loop
    sub $s3, $s3, $s3
    add $s3, $s3, $t8

# taking y coordinate
    li $v0, 4
    la $a0, prompty
    syscall

    li $v0, 5
    syscall
    move $t9, $v0 # curr y

# storing curr y, will be needed in next iteration of this loop
    sub $s4, $s4, $s4
    add $s4, $s4, $t9

# check which case (same side vs opposite side) (refer to accompanying pdf for details)
    mul $t3, $t7, $t9

    # li $v0, 1
    # la $a0, ($t3)
    # syscall

    bgtz $t3, positiv
    # li $v0, 4
    # la $a0,debug1
    # syscall

# opposite side case:
    # 1/2 d (l1^2 + l2^2)/(l1 + l2)
    abs $t7, $t7   # l1
    abs $t9, $t9   # l2
    sub $t3, $t6, $t8  # d
    abs $t3, $t3

    add $t4, $t7, $t9 # l1 + l2
    mul $t7, $t7, $t7
    mul $t9, $t9, $t9
    add $t5, $t7, $t9 # l1^2 + l2^2

# if l1 = l2 = 0, then prevent division by zero (AH almost missed this case)
    beqz $t5, next

# --------check OVERFLOW
    bltz $t3, over_flow
    bltz $t4, over_flow
    bltz $t7, over_flow
    bltz $t9, over_flow
    bltz $t5, over_flow

# converting ints to doubles
    mtc1.d $t5, $f6
    cvt.s.w $f6, $f6
    cvt.d.s $f6, $f6

    mtc1.d $t4, $f4
    cvt.s.w $f4, $f4
    cvt.d.s $f4, $f4

    mtc1.d $t3, $f2
    cvt.s.w $f2, $f2
    cvt.d.s $f2, $f2

    l.d $f8, half

# division done before multiplication (avoiding fake overflow)
    div.d $f6, $f6, $f4
    mul.d $f8, $f8, $f2

    mul.d $f6, $f6, $f8

# adding to ans, and storing back ans
    l.d $f10, ans
    add.d $f10, $f10, $f6
    s.d $f10, ans

# jump over other case
    b next

# same side case:
    positiv:
        # 1/2 d (l1 + l2)
        abs $t7, $t7 # l1
        abs $t9, $t9 # l2
        sub $t3, $t6, $t8 # d
# --------check OVERFLOW
        # blez $t3, over_flow
        abs $t3, $t3

        add $t7, $t7, $t9 # l1 = l2
        mul $t3, $t3, $t7 # d * (l1+l2)

# --------check OVERFLOW
        bltz $t7, over_flow
        bltz $t3, over_flow

#---------------------------------debugging
        # li $v0, 1
        # la $a0, ($t7)
        # syscall
        #
        # li $v0, 1
        # la $a0, ($t3)
        # syscall
        #
        # li $v0, 4
        # la $a0, newline
        # syscall
#-----------------------------

#  div by 2 now // so convert to float first
        mtc1.d $t3, $f6
        cvt.s.w $f6, $f6
        cvt.d.s $f6, $f6

        l.d $f8, half
        mul.d $f6, $f6, $f8

# adding to ans, and storing back ans
        l.d $f10, ans
        add.d $f10, $f10, $f6
        s.d $f10, ans

# jumps here from opposite side case
    next:

# moving (curr_x, curr_y) to (prev_x, prev_y)
    move $t6, $s3
    move $t7, $s4

# looping
    add $t2, $t2, 1
    blt $t2, $t0, main_loop


# print result
    l.d $f10, ans
    li $v0, 3
    mov.d $f12, $f10
    syscall

    l.d $f10, ans
    sub.d $f10, $f10, $f10
    s.d $f10, ans

# just to check that I didnt get caught in an infinite loop
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 4
    la $a0, NT
    syscall

# end program
    li $v0, 10
    syscall

# jumps here if overflow happens at any stage
    over_flow:
    li $v0, 4
    la $a0, prompt_overflow
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 10
    syscall

# jumps here if the input is not sorted by x (faulty inputs)
    wrong_input:
    li $v0, 4
    la $a0, prompt_wrong_in
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 10
    syscall





# flips over table in excitement
