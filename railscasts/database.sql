SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
CREATE DATABASE IF NOT EXISTS `railscasts` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `railscasts`;

CREATE TABLE IF NOT EXISTS `assignments` (
`id` int(11) NOT NULL,
  `episode_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `episodes` (
`id` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `name` varchar(300) NOT NULL,
  `url` varchar(400) NOT NULL,
  `description` varchar(1000) NOT NULL,
  `notes` varchar(30000) NOT NULL,
  `duration` time NOT NULL,
  `file_size` int(11) NOT NULL,
  `pro` tinyint(1) NOT NULL,
  `revised` tinyint(1) NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `tags` (
`id` int(11) NOT NULL,
  `tag` varchar(50) NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;


ALTER TABLE `assignments`
 ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `episode_id` (`episode_id`,`tag_id`);

ALTER TABLE `episodes`
 ADD PRIMARY KEY (`id`);

ALTER TABLE `tags`
 ADD PRIMARY KEY (`id`);


ALTER TABLE `assignments`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1;
ALTER TABLE `episodes`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1;
ALTER TABLE `tags`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1;
