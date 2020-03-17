/*
 Navicat MySQL Data Transfer

 Source Server         : 192.168.110.240
 Source Server Type    : MySQL
 Source Server Version : 50729
 Source Host           : 192.168.110.240:3306
 Source Schema         : test

 Target Server Type    : MySQL
 Target Server Version : 50729
 File Encoding         : 65001

 Date: 17/03/2020 17:18:51
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for gameLog
-- ----------------------------
DROP TABLE IF EXISTS `gameLog`;
CREATE TABLE `gameLog`  (
  `gameLogId` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '牌局ID',
  `betScore` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '玩家下注分数（JSON）',
  `resultScore` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '玩家结算分数（JSON）',
  `cardInfo` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家牌面值信息（JSON）',
  `updateTime` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`gameLogId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for gameScoreChangeLog
-- ----------------------------
DROP TABLE IF EXISTS `gameScoreChangeLog`;
CREATE TABLE `gameScoreChangeLog`  (
  `userId` int(11) NOT NULL DEFAULT 0 COMMENT '用户ID',
  `score` bigint(20) NULL DEFAULT 0 COMMENT '当前分数',
  `changeScore` int(11) NULL DEFAULT 0 COMMENT '分数改变值',
  `beforeScore` bigint(20) NULL DEFAULT 0 COMMENT '分数改变前的值',
  `updateTime` datetime(0) NULL DEFAULT NULL COMMENT '更新时间'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for matchServerInfo
-- ----------------------------
DROP TABLE IF EXISTS `matchServerInfo`;
CREATE TABLE `matchServerInfo`  (
  `serverId` int(11) NOT NULL DEFAULT 0 COMMENT '服务器ID',
  `serverName` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '服务器名字',
  `matchQueueLength` int(11) NULL DEFAULT NULL COMMENT '匹配队列长度',
  `matchSuccessCount` int(11) NULL DEFAULT NULL COMMENT '匹配成功次数',
  `matchDuration` int(11) NULL DEFAULT NULL COMMENT '匹配时长',
  `updateTime` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`serverId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for roomServerInfo
-- ----------------------------
DROP TABLE IF EXISTS `roomServerInfo`;
CREATE TABLE `roomServerInfo`  (
  `roomId` int(11) NOT NULL DEFAULT 0 COMMENT '房间ID',
  `roomName` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '房间名字',
  `roomOnlineCount` int(11) NULL DEFAULT 0 COMMENT '房间在线人数',
  `updateTime` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`roomId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `userId` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `userName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '用户名',
  `score` bigint(20) NULL DEFAULT 0 COMMENT '用户分数',
  `loginTime` datetime(0) NULL DEFAULT NULL COMMENT '登录时间',
  `registerTime` datetime(0) NULL DEFAULT NULL COMMENT '注册时间',
  `status` int(11) NULL DEFAULT 0 COMMENT '用户状态（0=正常， 1=禁止登录，2=封号）',
  `loginCount` int(11) NULL DEFAULT 0 COMMENT '登录次数',
  PRIMARY KEY (`userId`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10017 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (10000, 'gkju', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10001, 'rtef', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10002, 'yukyuy8', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10003, 'nmchng6', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10004, 'ghjgjdy35', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10005, 'sdgar434', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10006, 'ilijoik12', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10007, 'lmlkje', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10008, 'sdf', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10009, 'sdffg', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10010, 'fdgth', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10011, 'kjhjj', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10012, 'qweqb', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10013, 'hjdgjr', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10014, 'uiluyt', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10015, 'ioknk', 1000, NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (10016, '8ujiknkg', 1000, NULL, NULL, NULL, NULL);

SET FOREIGN_KEY_CHECKS = 1;
