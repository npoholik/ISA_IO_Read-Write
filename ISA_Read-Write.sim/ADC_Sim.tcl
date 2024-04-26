#----------------------------------------------------------------------------------------------------------
# Description: Simulation DO file for IO Read Portion
#              For sim clock is set to 10 ns Period (this is not accurate to design in practice, but useful for sim)
#----------------------------------------------------------------------------------------------------------
restart

# Waveforms of interest to ensure proper functionality
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

# These signals will be driven unchanged from the start of simulation
add_force {/board/mesa_4i30/user_design/clk_50} -radix hex {0 0ns} {1 10000ps} -repeat_every 20000ps
add_force {/board/mesa_4i30/IO16} -radix hex {1 0ns}
add_force {/board/mesa_4i30/MEM16} -radix hex {Z 0ns}
add_force {/board/mesa_4i30/CHRDY} -radix hex {1 0ns}
add_force {/board/mesa_4i30/IORC} -radix hex {0 0ns}
run 20 ns

#Below we will go through address+data phases one at a time with various data in the ADC 
#This will give an idea of when data enters the bus through SD, and if any discrepancies occur where the issues are 
# **** CURRENTLY INCOMPLETE, SD WILL BE DRIVEN TO HIGH Z HALFWAY THROUGH AS A RESULT OF THIS CONFIGURATION****
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

#add_force {/board/mesa_4i30/user_design/adcINT} -radix hex {0 0ns}
