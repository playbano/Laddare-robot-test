*** Variables ***
${PP_min}    SEPARATOR=:
${PP_min[CH_STATE_IDLE]}         10
${PP_min[CH_STATE_CABLE_CONN]}   6
${PP_min[CH_STATE_CAR_CONN]}     6
${PP_min[CH_STATE_CH_PWR]}       6
${PP_min[CH_STATE_CAR_REQ_PWR]}  6
${PP_min[CH_STATE_CHARGING]}     6

${PP_max}    SEPARATOR=:
${PP_max[CH_STATE_IDLE]}         13
${PP_max[CH_STATE_CABLE_CONN]}   8
${PP_max[CH_STATE_CAR_CONN]}     8
${PP_max[CH_STATE_CH_PWR]}       8
${PP_max[CH_STATE_CAR_REQ_PWR]}  8
${PP_max[CH_STATE_CHARGING]}     8

${CP_min}    SEPARATOR=:
${CP_min[CH_STATE_IDLE]}         10
${CP_min[CH_STATE_CABLE_CONN]}   10
${CP_min[CH_STATE_CAR_CONN]}     7.5
${CP_min[CH_STATE_CH_PWR]}       7.5
${CP_min[CH_STATE_CAR_REQ_PWR]}  5  #2
${CP_min[CH_STATE_CHARGING]}     5

${CP_max}    SEPARATOR=:
${CP_max[CH_STATE_IDLE]}         13
${CP_max[CH_STATE_CABLE_CONN]}   13
${CP_max[CH_STATE_CAR_CONN]}     11
${CP_max[CH_STATE_CH_PWR]}       11
${CP_max[CH_STATE_CAR_REQ_PWR]}  7  #2
${CP_max[CH_STATE_CHARGING]}     7