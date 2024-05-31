C     ==================================================================
C     Subroutine for solving the partial NNLS problem, modified from the 
C     NNLS subroutine downloaded from
C     http://www.netlib.org/lawson-hanson/all.  (Yong Wang, Department
C     of Statistics, University of Auckland, New Zealand. Email:
C     yongwang@auckland.ac.nz)
C     ==================================================================

C     SUBROUTINE PNNLS  (A,MDA,M,N,B,X,RNORM,W,ZZ,INDEX,MODE,K)
C   
C  Algorithm NNLS: NONNEGATIVE LEAST SQUARES
C   
c  The original version of this code was developed by
c  Charles L. Lawson and Richard J. Hanson at Jet Propulsion Laboratory
c  1973 JUN 15, and published in the book
c  "SOLVING LEAST SQUARES PROBLEMS", Prentice-HalL, 1974.
c  Revised FEB 1995 to accompany reprinting of the book by SIAM.
c
C     GIVEN AN M BY N MATRIX, A, AND AN M-VECTOR, B,  COMPUTE AN
C     N-VECTOR, X, THAT SOLVES THE LEAST SQUARES PROBLEM   
C   
C                      A * X = B  SUBJECT TO X .GE. 0   
C     ------------------------------------------------------------------
c                     Subroutine Arguments
c
C     A(),MDA,M,N     MDA IS THE FIRST DIMENSIONING PARAMETER FOR THE   
C                     ARRAY, A().   ON ENTRY A() CONTAINS THE M BY N    
C                     MATRIX, A.           ON EXIT A() CONTAINS 
C                     THE PRODUCT MATRIX, Q*A , WHERE Q IS AN   
C                     M BY M ORTHOGONAL MATRIX GENERATED IMPLICITLY BY  
C                     THIS SUBROUTINE.  
C     B()     ON ENTRY B() CONTAINS THE M-VECTOR, B.   ON EXIT B() CON- 
C             TAINS Q*B.
C     X()     ON ENTRY X() NEED NOT BE INITIALIZED.  ON EXIT X() WILL   
C             CONTAIN THE SOLUTION VECTOR.  
C     RNORM   ON EXIT RNORM CONTAINS THE EUCLIDEAN NORM OF THE  
C             RESIDUAL VECTOR.  
C     W()     AN N-ARRAY OF WORKING SPACE.  ON EXIT W() WILL CONTAIN    
C             THE DUAL SOLUTION VECTOR.   W WILL SATISFY W(I) = 0.  
C             FOR ALL I IN SET P  AND W(I) .LE. 0. FOR ALL I IN SET Z   
C     ZZ()     AN M-ARRAY OF WORKING SPACE.     
C     INDEX()     AN INTEGER WORKING ARRAY OF LENGTH AT LEAST N.
C                 ON EXIT THE CONTENTS OF THIS ARRAY DEFINE THE SETS    
C                 P AND Z AS FOLLOWS..  
C   
C                 INDEX(1)   THRU INDEX(NSETP) = SET P.     
C                 INDEX(IZ1) THRU INDEX(IZ2)   = SET Z.     
C                 IZ1 = NSETP + 1 = NPP1
C                 IZ2 = N   
C     MODE    THIS IS A SUCCESS-FAILURE FLAG WITH THE FOLLOWING 
C             MEANINGS. 
C             1     THE SOLUTION HAS BEEN COMPUTED SUCCESSFULLY.
C             2     THE DIMENSIONS OF THE PROBLEM ARE BAD.  
C                   EITHER M .LE. 0 OR N .LE. 0.
C             3    ITERATION COUNT EXCEEDED.  MORE THAN 3*N ITERATIONS. 
C   
C
C     K       The first K variables are not NN-restricted, but they are
C             subject to the examination of linear dependence and some 
C             of them may be excluded
C
C     ------------------------------------------------------------------
      SUBROUTINE PNNLS  (A,MDA,M,N,B,X,RNORM,W,ZZ,INDEX,MODE,K) 
C     ------------------------------------------------------------------
      integer I, II, IP, ITER, ITMAX, IZ, IZ1, IZ2, IZMAX, J, JJ, JZ, L
      integer M, MDA, MODE,N, NPP1, NSETP, RTNKEY, K, NK
c     integer INDEX(N)  
c     double precision A(MDA,N), B(M), W(N), X(N), ZZ(M)   
      integer INDEX(*)  
      double precision A(MDA,*), B(*), W(*), X(*), ZZ(*)   
      double precision ALPHA, ASAVE, CC, DIFF, DUMMY(MDA), FACTOR, RNORM
      double precision SM, SS, T, TEMP, TWO, UNORM, UP, WMAX
      double precision ZERO, ZTEST
      parameter(FACTOR = 0.01d0)
      parameter(TWO = 2.0d0, ZERO = 0.0d0)
C     ------------------------------------------------------------------

      JJ=0
      MODE=1
      IF (M .le. 0 .or. N .le. 0) then
         MODE=2
         RETURN
      endif
      ITER=0
      ITMAX=3*N 
C   
C                    INITIALIZE THE ARRAYS INDEX() AND X(). 
C   
      DO 20 I=1,N   
         X(I)=ZERO     
         INDEX(I)=I
 20   enddo         
C   
      IZ2=N 

C     --- Yong's code starts here ---

      IZ1=K+1 
      NK=0

C     Householder transformation for the frist K variables
      
      if (K .gt. 0) go to 500
      K=NK
      NSETP=K
      NPP1=NSETP+1
      go to 30

 500  do 560 JK=1, K
         J = INDEX(NK+1)
         ASAVE=A(NK+1,J)   
         CALL H12 (1,NK+1,NK+2,M,A(1,J),1,UP,DUMMY,1,1,0)    
         UNORM=ZERO
         IF (NK .ne. 0) then
            DO 510 L=1,NK
               UNORM=UNORM+A(L,J)**2
 510        enddo               
         endif
         UNORM=sqrt(UNORM) 
         IF (DIFF(UNORM+ABS(A(NK+1,J))*FACTOR,UNORM) .gt. ZERO) then
            CALL H12 (2,NK+1,NK+2,M,A(1,J),1,UP,B,1,1,1)
            NK=NK+1
            DO 520 JZ=NK+1,IZ2 
               JJ=INDEX(JZ)  
               CALL H12 (2,NK,NK+1,M,A(1,J),1,UP,A(1,JJ),1,MDA,1)
 520        continue
            IF (NK .ne. M) then
               DO 530 L=NK+1,M   
                  A(L,J)=ZERO
 530           enddo                  
            endif
         else 
            A(NK+1,J)=ASAVE 
            if (NK+1 .le. IZ1-2) then
               do 540 IK=NK+1,IZ1-2
                  INDEX(IK) = INDEX(IK+1)
 540           enddo                  
            endif
            if (IZ1 .le. IZ2) then
               do 550 IK=IZ1,IZ2
                  INDEX(IK-1) = INDEX(IK)
 550           enddo                  
            endif
            INDEX(IZ2) = J   
            IZ1=IZ1-1
         endif
 560  continue
      K=NK
      NSETP=K
      NPP1=NSETP+1
      RTNKEY=3
      JJ=NSETP
      do 570 IP=1,NK
         ZZ(IP)=B(IP)
 570  enddo         
      go to 400
 580  continue
      do 590 IP=1,NK
         L = INDEX(IP)
         X(L)=ZZ(IP)
 590  end do

C     Up to this point, the vector INDEX has two parts: the first K elements 
C     store the indexes of free variables, and the remaining ones for those 
C     initially allocated to set Z (zero).

C     --- Yong's code ends here ---


C                             ******  MAIN LOOP BEGINS HERE  ******     

 30   CONTINUE  
C                  QUIT IF ALL COEFFICIENTS ARE ALREADY IN THE SOLUTION.
C                        OR IF M COLS OF A HAVE BEEN TRIANGULARIZED.    
C   
      IF (IZ1 .GT.IZ2.OR.NSETP.GE.M) GO TO 350   
C   
C         COMPUTE COMPONENTS OF THE DUAL (NEGATIVE GRADIENT) VECTOR W().
C   
      DO 50 IZ=IZ1,IZ2  
         J=INDEX(IZ)   
         SM=ZERO   
         DO 40 L=NPP1,M
            SM=SM+A(L,J)*B(L)
 40      enddo            
         W(J)=SM   
 50   continue
C                                   FIND LARGEST POSITIVE W(J). 
 60   continue
      WMAX=ZERO
      IZMAX=0
      DO 70 IZ=IZ1,IZ2  
         J=INDEX(IZ)   
         IF (W(J) .gt. WMAX) then
            WMAX=W(J)     
            IZMAX=IZ  
         endif
 70   CONTINUE  
C   
C             IF WMAX .LE. 0. GO TO TERMINATION.
C             THIS INDICATES SATISFACTION OF THE KUHN-TUCKER CONDITIONS.
C   
      IF (WMAX .le. ZERO) go to 350
      IZ=IZMAX  
      J=INDEX(IZ)   
C   
C     THE SIGN OF W(J) IS OK FOR J TO BE MOVED TO SET P.    
C     BEGIN THE TRANSFORMATION AND CHECK NEW DIAGONAL ELEMENT TO AVOID  
C     NEAR LINEAR DEPENDENCE.   
C   
      ASAVE=A(NPP1,J)   
      CALL H12 (1,NPP1,NPP1+1,M,A(1,J),1,UP,DUMMY,1,1,0)    
      
      UNORM=ZERO
      IF (NSETP .ne. 0) then
         DO 90 L=1,NSETP   
            UNORM=UNORM+A(L,J)**2
 90      enddo            
      endif
      UNORM=sqrt(UNORM) 
      IF (DIFF(UNORM+ABS(A(NPP1,J))*FACTOR,UNORM) .gt. ZERO) then
C   
C        COL J IS SUFFICIENTLY INDEPENDENT.  COPY B INTO ZZ, UPDATE ZZ
C        AND SOLVE FOR ZTEST ( = PROPOSED NEW VALUE FOR X(J) ).    
C   
         DO 120 L=1,M  
            ZZ(L)=B(L)
 120     enddo            
         CALL H12 (2,NPP1,NPP1+1,M,A(1,J),1,UP,ZZ,1,1,1)   
         ZTEST=ZZ(NPP1)/A(NPP1,J)  
C   
C                                     SEE IF ZTEST IS POSITIVE  
C   
         IF (ZTEST .gt. ZERO) go to 140
      endif
C   
C     REJECT J AS A CANDIDATE TO BE MOVED FROM SET Z TO SET P.  
C     RESTORE A(NPP1,J), SET W(J)=0., AND LOOP BACK TO TEST DUAL
C     COEFFS AGAIN.     
C   
      A(NPP1,J)=ASAVE   
      W(J)=ZERO 
      GO TO 60  
C   
C     THE INDEX  J=INDEX(IZ)  HAS BEEN SELECTED TO BE MOVED FROM
C     SET Z TO SET P.    UPDATE B,  UPDATE INDICES,  APPLY HOUSEHOLDER  
C     TRANSFORMATIONS TO COLS IN NEW SET Z,  ZERO SUBDIAGONAL ELTS IN   
C     COL J,  SET W(J)=0.   
C   
 140  continue

      DO 150 L=1,M  
         B(L)=ZZ(L)
 150  enddo         
C     
      INDEX(IZ)=INDEX(IZ1)  
      INDEX(IZ1)=J  
      IZ1=IZ1+1 
      NSETP=NPP1
      NPP1=NPP1+1   
C   
      IF (IZ1 .le. IZ2) then
         DO 160 JZ=IZ1,IZ2 
            JJ=INDEX(JZ)  
            CALL H12 (2,NSETP,NPP1,M,A(1,J),1,UP,A(1,JJ),1,MDA,1)
 160     continue
      endif
C   
      IF (NSETP .ne. M) then
         DO 180 L=NPP1,M   
            A(L,J)=ZERO
 180     enddo            
      endif
C   
      W(J)=ZERO 
C                                SOLVE THE TRIANGULAR SYSTEM.   
C                                STORE THE SOLUTION TEMPORARILY IN ZZ().
      RTNKEY = 1
      GO TO 400 
 200  CONTINUE  
C   
C                       ******  SECONDARY LOOP BEGINS HERE ******   
C   
C                          ITERATION COUNTER.   
C 
 210  continue  
      ITER=ITER+1   
      IF (ITER .gt. ITMAX) then
         MODE=3
cc         write (*,'(/a)') ' NNLS quitting on iteration count.'
         Continue
         GO TO 350 
      endif
C   
C                    SEE IF ALL NEW CONSTRAINED COEFFS ARE FEASIBLE.    
C                                  IF NOT COMPUTE ALPHA.    
C   
      ALPHA=TWO 
      DO 240 IP=K+1,NSETP 
         L=INDEX(IP)   
         IF (ZZ(IP) .le. ZERO) then
            T=-X(L)/(ZZ(IP)-X(L))     
            IF (ALPHA .gt. T) then
               ALPHA=T   
               JJ=IP 
            endif
         endif
 240  CONTINUE  
C   
C          IF ALL NEW CONSTRAINED COEFFS ARE FEASIBLE THEN ALPHA WILL   
C          STILL = 2.    IF SO EXIT FROM SECONDARY LOOP TO MAIN LOOP.   
C   
      IF (ALPHA.EQ.TWO) GO TO 330   
C   
C          OTHERWISE USE ALPHA WHICH WILL BE BETWEEN 0. AND 1. TO   
C          INTERPOLATE BETWEEN THE OLD X AND THE NEW ZZ.    
C   
      DO 250 IP=K+1,NSETP 
         L=INDEX(IP)   
         X(L)=X(L)+ALPHA*(ZZ(IP)-X(L)) 
 250  continue
C   
C        MODIFY A AND B AND THE INDEX ARRAYS TO MOVE COEFFICIENT I  
C        FROM SET P TO SET Z.   
C   
      I=INDEX(JJ)   
 260  continue
      X(I)=ZERO 
C   
      IF (JJ .ne. NSETP) then
         JJ=JJ+1   
         DO 280 J=JJ,NSETP 
            II=INDEX(J)   
            INDEX(J-1)=II 
            CALL G1 (A(J-1,II),A(J,II),CC,SS,A(J-1,II))   
            A(J,II)=ZERO  
            DO 270 L=1,N  
               IF (L.NE.II) then
c
c                 Apply procedure G2 (CC,SS,A(J-1,L),A(J,L))  
c
                  TEMP = A(J-1,L)
                  A(J-1,L) = CC*TEMP + SS*A(J,L)
                  A(J,L)   =-SS*TEMP + CC*A(J,L)
               endif
 270        CONTINUE  
c
c                 Apply procedure G2 (CC,SS,B(J-1),B(J))   
c
            TEMP = B(J-1)
            B(J-1) = CC*TEMP + SS*B(J)    
            B(J)   =-SS*TEMP + CC*B(J)    
 280     continue
      endif
c
      NPP1=NSETP
      NSETP=NSETP-1     
      IZ1=IZ1-1 
      INDEX(IZ1)=I  
C   
C        SEE IF THE REMAINING COEFFS IN SET P ARE FEASIBLE.  THEY SHOULD
C        BE BECAUSE OF THE WAY ALPHA WAS DETERMINED.
C        IF ANY ARE INFEASIBLE IT IS DUE TO ROUND-OFF ERROR.  ANY   
C        THAT ARE NONPOSITIVE WILL BE SET TO ZERO   
C        AND MOVED FROM SET P TO SET Z. 
C     
      DO 300 JJ=K+1,NSETP 
         I=INDEX(JJ)   
         IF (X(I) .le. ZERO) go to 260
 300  CONTINUE  
C   
C         COPY B( ) INTO ZZ( ).  THEN SOLVE AGAIN AND LOOP BACK.
C   
      DO 310 I=1,M  
         ZZ(I)=B(I)
 310  enddo         
      RTNKEY = 2
      GO TO 400 
 320  CONTINUE  
      GO TO 210 
C                      ******  END OF SECONDARY LOOP  ******
C   
 330  continue
      DO 340 IP=1,NSETP 
         I=INDEX(IP)   
         X(I)=ZZ(IP)
 340  enddo         
C        ALL NEW COEFFS ARE POSITIVE.  LOOP BACK TO BEGINNING.  
      GO TO 30  
C   
C                        ******  END OF MAIN LOOP  ******   
C   
C                        COME TO HERE FOR TERMINATION.  
C                     COMPUTE THE NORM OF THE FINAL RESIDUAL VECTOR.    
C 
 350  continue  
      SM=ZERO   
      IF (NPP1 .le. M) then
         DO 360 I=NPP1,M   
            SM=SM+B(I)**2
 360     enddo            
      else
         DO 380 J=K+1,N  
            W(J)=ZERO
 380     enddo            
      endif
      RNORM=sqrt(SM)    
      RETURN
C   
C     THE FOLLOWING BLOCK OF CODE IS USED AS AN INTERNAL SUBROUTINE     
C     TO SOLVE THE TRIANGULAR SYSTEM, PUTTING THE SOLUTION IN ZZ().     
C   
 400  continue
      DO 430 L=1,NSETP  
         IP=NSETP+1-L  
         IF (L .ne. 1) then
            DO 410 II=1,IP
               ZZ(II)=ZZ(II)-A(II,JJ)*ZZ(IP+1)   
 410        continue
         endif
         JJ=INDEX(IP)  
         ZZ(IP)=ZZ(IP)/A(IP,JJ)    
 430  continue
c      go to (200, 320, 580), RTNKEY
      if (RTNKEY .eq. 1) goto 200
      if (RTNKEY .eq. 2) goto 320
      if (RTNKEY .eq. 3) goto 580
      END

