//
//  ApiResult.swift
//  ManageIOT_Volunteer
//
//  Created by Scott on 2021/5/17.
//  Copyright © 2021 Admin. All rights reserved.
//

import Foundation

class ApiResult {
    static let SUCCESS = 200
    static let OTHER = 300
    static let TOKEN_BLANK = 301
    static let API_NOT_EXIST = 302
    static let API_PARAM_BLANK = 303
    static let ACTION_BLANK = 304
    static let DB_NO_FIND = 305
    static let LOGIC_ERROR = 306
    static let NO_PRIORITY = 307
    static let NO_DEVICE = 308
    static let NO_ALARM_TYPE = 309
    static let NO_ALARM = 310
    static let NO_ALARM_TASK = 311
    static let NO_ALARM_TASK_SUB = 312
    static let DUPLICATE_ALARM = 313
    static let PHONE_BLANK = 201
    static let PHONE_INVAILD = 202
    static let PHONE_FAIL = 203
    static let PHONE_NOT_EXIST = 205
    static let PHONE_REGISTERED = 206
    static let PASSWORD_BLANK = 211
    static let PASSWORD_INVAILD = 212
    static let PASSWORD_FAIL = 213
    static let PASSWORD_CONFORM_NOT_SAME = 215
    static let PASSWORD_NEW_SAME = 216
    static let PASSWORD_OLD_FAIL = 217
    static let VALIDATE_CODE_BLANK = 221
    static let VALIDATE_CODE_INVALID = 222
    static let VALIDATE_CODE_FAIL = 223
    static let VALIDATE_CODE_EXPIRED = 224
    static let ITEM_ID_BLANK = 231
    static let ITEM_ID_INVALID = 232
    static let ITEM_ID_FAIL = 233
    static let ITEM_TYPE_INVALID = 234
    static let ITEM_OTHER_REGISTERED = 235
    static let WATCH_ID_BLANK = 236
    static let WATCH_ID_INVALID = 237
    static let ROLE_NAME_EXIST = 241
    static let ROLE_USED = 242
    static let ACCOUNT_BLANK = 261
    static let ACCOUNT_INVALID = 262
    static let ACCOUNT_FAIL = 263
    static let ACCOUNT_OTHER_LOGINED = 265
    static let ACCOUNT_REGISTERED = 266
    static let ACCOUNT_NOT_EXIST = 267
    static let ACCOUNT_EXPIRED = 268
    static let CHAT_ROOM_BUSY = 401
    static let CHAT_KEFU_BUSY = 402
    static let DEVICE_STATUS_OFFLINE = 411
    static let WATCH_STATUS_TAKEOFF = 416
    static let PAY_FAILED = 500
    static let PAY_PRE_FAILED = 501
    static let PAY_NOT_EXIST = 502
    static let PAY_IN_PROCESS = 503
}
