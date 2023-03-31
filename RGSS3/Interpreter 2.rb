class Interpreter

  def execute_command
    if @index >= @list.size - 1
      command_end
      return true
    end
    
    @parameters = @list[@index].parameters
    case @list[@index].code
    when 101
      return command_101
    when 102  
      return command_102
    when 402  
      return command_402
    when 403  
      return command_403
    when 103  
      return command_103
    when 104  
      return command_104
    when 105  
      return command_105
    when 106  
      return command_106
    when 111  
      return command_111
    when 411  
      return command_411
    when 112  
      return command_112
    when 413  
      return command_413
    when 113  
      return command_113
    when 115  
      return command_115
    when 116  
      return command_116
    when 117  
      return command_117
    when 118  
      return command_118
    when 119  
      return command_119
    when 121  
      return command_121
    when 122  
      return command_122
    when 123  
      return command_123
    when 124  
      return command_124
    when 125  
      return command_125
    when 126  
      return command_126
    when 127  
      return command_127
    when 128  
      return command_128
    when 129  
      return command_129
    when 131  
      return command_131
    when 132  
      return command_132
    when 133  
      return command_133
    when 134  
      return command_134
    when 135  
      return command_135
    when 136  
      return command_136
    when 201  
      return command_201
    when 202  
      return command_202
    when 203  
      return command_203
    when 204  
      return command_204
    when 205  
      return command_205
    when 206  
      return command_206
    when 207  
      return command_207
    when 208  
      return command_208
    when 209  
      return command_209
    when 210  
      return command_210
    when 221  
      return command_221
    when 222  
      return command_222
    when 223  
      return command_223
    when 224  
      return command_224
    when 225  
      return command_225
    when 231  
      return command_231
    when 232  
      return command_232
    when 233  
      return command_233
    when 234  
      return command_234
    when 235  
      return command_235
    when 236  
      return command_236
    when 241  
      return command_241
    when 242  
      return command_242
    when 245  
      return command_245
    when 246  
      return command_246
    when 247  
      return command_247
    when 248  
      return command_248
    when 249  
      return command_249
    when 250  
      return command_250
    when 251  
      return command_251
    when 301  
      return command_301
    when 601  
      return command_601
    when 602  
      return command_602
    when 603  
      return command_603
    when 302  
      return command_302
    when 303  
      return command_303
    when 311  
      return command_311
    when 312  
      return command_312
    when 313  
      return command_313
    when 314  
      return command_314
    when 315  
      return command_315
    when 316  
      return command_316
    when 317  
      return command_317
    when 318  
      return command_318
    when 319  
      return command_319
    when 320  
      return command_320
    when 321  
      return command_321
    when 322  
      return command_322
    when 331  
      return command_331
    when 332  
      return command_332
    when 333  
      return command_333
    when 334  
      return command_334
    when 335  
      return command_335
    when 336  
      return command_336
    when 337  
      return command_337
    when 338  
      return command_338
    when 339  
      return command_339
    when 340  
      return command_340
    when 351  
      return command_351
    when 352  
      return command_352
    when 353  
      return command_353
    when 354  
      return command_354
    when 355  
      return command_355
    else      
      return true
    end
  end

  def command_end
    @list = nil
    if @main and @event_id > 0
      $game_map.events[@event_id].unlock
    end
  end

  def command_skip
    indent = @list[@index].indent
    loop do
      if @list[@index+1].indent == indent
        return true
      end
      @index += 1
    end
  end

  def get_character(parameter)
    case parameter
    when -1  
      return $game_player
    when 0  
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else  
      events = $game_map.events
      return events == nil ? nil : events[parameter]
    end
  end

  def operate_value(operation, operand_type, operand)
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    if operation == 1
      value = -value
    end
    return value
  end
end