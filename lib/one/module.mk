            libs := libone
           tests := test_1b bbtest

   libone_cfiles := one_a.c one_b.c

  test_1b_cfiles := one_b.c
test_1b_CPPFLAGS := -DTEST_ONE_B

   bbtest_cfiles := bbtest.c
     bbtest_libs := libone
