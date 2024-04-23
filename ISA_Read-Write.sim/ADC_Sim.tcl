restart
add_wave {{/board/mesa_4i30/SD}} 

add_wave {{/board/mesa_4i30/IOWC}} 

add_wave {{/board/mesa_4i30/IORC}} 

add_wave {{/board/mesa_4i30/IO16}} 

add_wave {{/board/mesa_4i30/MEM16}} 

add_wave {{/board/mesa_4i30/CHRDY}} 

add_wave {{/board/mesa_4i30/user_design/countOut}} 
add_wave {{/board/mesa_4i30/user_design/adcData}} 
add_wave {{/board/mesa_4i30/user_design/adcWrite}} 
add_wave {{/board/mesa_4i30/user_design/adcINT}} 
add_wave {{/board/mesa_4i30/user_design/valid}} 
add_force {/board/mesa_4i30/user_design/clk_50} -radix hex {0 0ns} {1 10000ps} -repeat_every 20000ps
add_force {/board/mesa_4i30/IO16} -radix hex {1 0ns}
add_force {/board/mesa_4i30/MEM16} -radix hex {Z 0ns}
add_force {/board/mesa_4i30/CHRDY} -radix hex {1 0ns}
add_force {/board/mesa_4i30/IORC} -radix hex {0 0ns}
run 20 ns
add_force {/board/mesa_4i30/user_design/adcINT} -radix hex {1 0ns}
add_force {/board/mesa_4i30/user_design/adcData} -radix hex {xFF 0ns}
run 20 ns
add_force {/board/mesa_4i30/user_design/adcINT} -radix hex {0 0ns}
run 20 ns
add_force {/board/mesa_4i30/user_design/adcINT} -radix hex {1 0ns}
add_force {/board/mesa_4i30/user_design/adcData} -radix hex {xAA 0ns}
run 20 ns
add_force {/board/mesa_4i30/user_design/adcINT} -radix hex {0 0ns}
run 20 ns
add_force {/board/mesa_4i30/user_design/adcINT} -radix hex {1 0ns}
add_force {/board/mesa_4i30/user_design/adcData} -radix hex {x55 0ns}

run 20 ns
add_force {/board/mesa_4i30/user_design/adcINT} -radix hex {0 0ns}
