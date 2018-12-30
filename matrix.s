# CMPT-295
# Matthew Doyle 301322233
# Oct 29 2018 

# matrix.s
#
# Purpose:			
#	copy           - Copies a N x N matrix
#	transpose      - Transposes a N x N matrix
#	reverseColumns - Reverses the columns of a N x N matrix
# 	multiply 	   - Multiplies the square matrix A with the square matrix B, both of dimension 
#            		 N x N, and stores the result in square matrix C
#	dotProduct	   - With its first parameter set to the address of the first element of a row of A,
#					 its second parameter set to the address of the first element of column B,
# 				     its third parameter set to N. It computes the result for the corresponding cell of matrix C
# 
 

#####################
# A in rdi, B in rsi, N in edx, i in ecx, j in r8d
# char dotProduct(void *A, void *B, int N, int i, int j);

    .globl dotProduct
dotProduct:               
	xorl %eax, %eax		# set eax to 0
	movl $0, %r9d		# index i = 0

loopDP:
	cmpl %edx, %r9d		# loop as long as i - N < 0
	jge doneLoopDP

	movl (%rdi), %r10d 	# move A into tmp
	imull (%rsi), %r10d	# A * B
	addl %r10d, %eax	# returnValue += A*B
	
	# increment pointers
	incq %rdi 			# *A + 1
	addq %rdx, %rsi 	# *B + N

	incl %r9d			# update loop index
	jmp loopDP

doneLoopDP:
 	ret


#####################
# A in rdi, B in rsi, C in rdx, N in ecx
# void multiply(void *A, void *B, void *C, int N);            

   .globl multiply
multiply:
	xorl %eax, %eax		# set eax to 0	
	xorl %r8d, %r8d		# row index i is in r8d -> i = 0

rowLoopM:
	movl $0, %r9d		# column index j in r9d -> j = 0
	cmpl %ecx, %r8d		# loop as long as i - N < 0
	jge doneWithRowsM

colLoopM:
	cmpl %ecx, %r9d		# loop as long as j - N < 0
	jge doneWithCellsM

	# Compute the address of cell C[i][j]
	movl %ecx, %r15d	# r15d = N
	imull %r8d, %r15d 	# r15d = i * N
	addl %r9d, %r15d 	# r15d = j + i * N
	imull $1, %r15d		# r15d = L * (j + i * N) -> L is char (1 byte)
	addq %rdx, %r15 	# r15 = C + L * (j + i * N) -> C[i][j] in r15

	# Compute the adress of cell A[i][0]
	movl %ecx, %r14d	# r14d = N
	imull %r8d, %r14d 	# r14d = i * N
	addl $0, %r14d 		# r14d = 0 + i * N
	imull $1, %r14d		# r14d = L * (j + i * N) -> L is char (1 byte)
	addq %rdi, %r14 	# r14 = A + L * (j + i * N) -> A[i][0] in r14

	# Compute the adress of cell B[0][j]
	movl %ecx, %r13d	# r13d = N
	imull $0, %r13d 	# r13d = i * N
	addl %r9d, %r13d 	# r13d = j + i * N
	imull $1, %r13d		# r13d = L * (j + i * N) -> L is char (1 byte)
	addq %rsi, %r13 	# r13 = B + L * (j + i * N) -> B[0][j] in r13

	# Set C[i][j] = 0
	movq $0, (%r15)

# A in rdi, B in rsi, C in rdx, N in ecx
	# Push to stack
	pushq %rdi 			# Save A
	pushq %rsi 			# Save B
	pushq %rdx			# Save C
	pushq %rcx			# Save N
	pushq %r15 			# Save C[i][j]
	pushq %r8 			# Preserve i
	pushq %r9 			# Preserve j

	# Move arguments into correct locations to call dotProduct
	movq %r14, %rdi
	movq %r13, %rsi
	movl %ecx, %edx
	movl %r8d, %ecx
	movl %r9d, %r8d

	callq dotProduct 	# dotProduct(void *A, void *B, int N, int i, int j)
	# 					#				 rdi,     rsi,   edx,   ecx,   r8d
	
	# Restore values
	popq %r9			# j
	popq %r8			# i
	popq %r15 			# C[i][j]
	popq %rcx			# N
	popq %rdx			# C
	popq %rsi 			# B	
	popq %rdi 			# A

	movq %rax, (%r15)	# set C[i][j] to return value of dotProduct

	incl %r9d			# column index j++
	jmp colLoopM

# Go to next row
doneWithCellsM:
	incl %r8d			# row index i++ (in r8d)
	jmp rowLoopM

doneWithRowsM:				# return
	ret


#####################
	.globl	copy
copy:
# A in rdi, C in rsi, N in edx
	xorl %eax, %eax			# set eax to 0
# since this function is a leaf function, no need to save caller-saved registers rcx and r8
	xorl %ecx, %ecx			# row index i is in ecx -> i = 0

# For each row
rowLoopC:
	movl $0, %r8d			# column index j in r8d -> j = 0
	cmpl %edx, %ecx			# loop as long as i - N < 0
	jge doneWithRowsC

# For each cell of this row
colLoopC:
	cmpl %edx, %r8d			# loop as long as j - N < 0
	jge doneWithCellsC

# Compute the address of current cell that is copied from A to C
# since this function is a leaf function, no need to save caller-saved registers r10 and r11
	movl %edx, %r10d        # r10d = N 
    imull %ecx, %r10d		# r10d = i*N
	addl %r8d, %r10d        # j + i*N
	imull $1, %r10d         # r10 = L * (j + i*N) -> L is char (1Byte)
	movq %r10, %r11			# r11 = L * (j + i*N) 
	addq %rdi, %r10			# r10 = A + L * (j + i*N)
	addq %rsi, %r11			# r11 = C + L * (j + i*N)

# Copy A[L * (j + i*N)] to C[L * (j + i*N)]
	movb (%r10), %r9b       # temp = A[L * (j + i*N)]
	movb %r9b, (%r11)       # C[L * (j + i*N)] = temp

	incl %r8d				# column index j++ (in r8d)
	jmp colLoopC			# go to next cell

# Go to next row
doneWithCellsC:
	incl %ecx				# row index i++ (in ecx)
	jmp rowLoopC			# Play it again, Sam!

doneWithRowsC:				# bye! bye!
	ret


#####################
# Note: address A[i][j] is A+i*(C*L)+j*L type T requires L bytes
# C in rdi, n in esi
# void transpose(void *D, int n) {
# 	int i,j;
# 	char tmp;
# 	for (i = 0; i < n; i++) {
# 		for (j = 0; j < i; j++) {
# 			tmp = *((char*)(D + i*n + j));
# 			*((char*)(D + i*n + j)) = *((char*)(D + j*n + i));
# 			*((char*)(D + j*n + i)) = tmp;
# 		}
# 	}
# }

	.globl	transpose

transpose:
xorl %eax, %eax			# Set eax to 0
# since this function is a leaf function, no need to save caller-saved registers
xorl %edx, %edx			# Row i is in edx -> i = 0

# For each row
transposeRowLoop:
	xorl %ecx, %ecx		# Col j is in ecx -> j = 0
	cmpl %esi, %edx		# Loop as long as i - N < 0
	jge transposeDoneWithRows

# For each cell in the row
transposeColLoop:
	cmpl %edx, %ecx		# Loop as long as j - i < 0 check this
	jge transposeDoneWithCells

# Compute the address of cell C[i][j]
	movl %esi, %r8d		# r8d = N
	imull %edx, %r8d	#r8d = i * N
	addl %ecx, %r8d 	# j + i * N
	imull $1, %r8d		# r8d = L * (j + i * N) -> L is char (1 byte)
	addq %rdi, %r8 		# r8 = C + L * (j + i * N) -> C[i][j] (r8)

# Compute the address of cell C[j][i]
	movl %esi, %r9d		# r9d = N
	imull %ecx, %r9d	# r9d = j * N
	addl %edx, %r9d		# i + j * N
	imull $1, %r9d		# r9d = L * (i + j * N) -> L is char (1 byte)
	addq %rdi, %r9 		# r9 = C + L * (i + j * N) -> C[j][i] (r9)

# Swap
	movb (%r8), %r10b	# tmp (r10b) = C[i][j] (r8)
	movb (%r9), %r11b	# tmp2 (r11b) = C[j][i] (r9)
	movb %r10b, (%r9)	# C[j][i] (r9) = tmp (r10b)
	movb %r11b, (%r8)	# C[i][j] (r8) = tmp2 (r11b)

	incl %ecx			# Col number j++ (in ecx)
	jmp transposeColLoop

# Go to next row
transposeDoneWithCells:
	incl %edx			# Row number i++ (in edx)
	jmp transposeRowLoop

transposeDoneWithRows:
	ret


#####################
# C in rdi, N in esi
# void reverseColumns(void * D, int n) {
#     int i,j;
#     char tmp;

#     for (i = 0; i < N; i++) {
#         for (j= 0; j < N/2; j++) {
#            tmp = *((char*)(D + i*n + j));                                  // swap (C[i][j], C[i][N-j-1])
#            *((char*)(D + i*n + j)) = *((char*)(D + i*n + (N-j-1)));
#            *((char*)(D + i*n + (N-j-1))) = tmp;
#         }
#     }
# }

	.globl	reverseColumns

reverseColumns:
	xorl %eax, %eax		# Set eax to 0
	# since this function is a leaf function, no need to save caller-saved registers
	xorl %edx, %edx		# Row i is in edx -> i = 0

# For each row
reverseColumnsRowLoop:
	xorl %ecx, %ecx		# Col j is in ecx -> j = 0
	cmpl %esi, %edx		# Loop as long as i - N < 0
	jge reverseColumnsDoneWithRows

# For each cell in the row
reverseColumnsColLoop:
	movl %esi, %r15d	# r15d = N
	sar $1, %r15d		# Compute N/2 in r15d
	cmpl %r15d, %ecx	# Loop as long as j - N/2 < 0
	jge reverseColumnsDoneWithCells

# Compute the address of cell C[i][j]
	movl %esi, %r8d		# r8d = N
	imull %edx, %r8d	#r8d = i * N
	addl %ecx, %r8d 	# j + i * N
	imull $1, %r8d		# r8d = L * (j + i * N) -> L is char (1 byte)
	addq %rdi, %r8 		# r8 = C + L * (j + i * N) -> C[i][j] (r8)

# Compute the address of cell C[i][N-j-1]
	movl %esi, %r9d		# r9d = N
	imull %edx, %r9d	# r9d = i * N
	# Compute [N-j-1]
	movl %esi,%r14d		# r14d = N
	subl %ecx, %r14d	# r14d = N-j
	subl $1, %r14d		# r14d = N-j-1
	# Continue computing address
	addl %r14d, %r9d 	# (N-j-1) + i * N
	imull $1, %r9d		# r9d = L * ((N-j-1) + i * N) -> L is char (1 byte)
	addq %rdi, %r9 		# r9 = C + L * ((N-j-1) + i * N) -> C[i][N-j-1] (r9)

	# Swap
	movb (%r8), %r10b	# tmp (r10b) = C[i][j] (r8)
	movb (%r9), %r11b	# tmp2 (r11b) = C[i][N-j-1] (r9)
	movb %r10b, (%r9)	# C[i][N-j-1] (r9) = tmp (r10b)
	movb %r11b, (%r8)	# C[i][j] (r8) = tmp2 (r11b)
	incl %ecx			# Col number j++ (in ecx)
	jmp reverseColumnsColLoop

# Go to next row
reverseColumnsDoneWithCells:
	incl %edx			# Row number i++ (in edx)
	jmp reverseColumnsRowLoop

reverseColumnsDoneWithRows:
	ret
