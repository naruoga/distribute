#
# Aipo is a groupware program developed by Aimluck,Inc.
# Copyright (C) 2004-2015 Aimluck,Inc.
# http://www.aipo.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require 'fileutils'
require 'date'

LATEST_BRANCH        = "master"
STABLE_BRANCH        = "master"
NOW                  =  DateTime.now.strftime("%Y%m%d")
LATEST_VERSION       = "latest-#{NOW}"
LATEST_VERSION_SHORT = "latest-#{NOW}"
STABLE_VERSION       = "8.0.0.0"
STABLE_VERSION_SHORT = "8.0"

BUILD_DIR            = File.expand_path("build")
BUILD_DIST_DIR       = File.expand_path("build/dist")
BUILD_DIST_X64_DIR   = File.expand_path("build/dist/x64")
BUILD_DIST_X86_DIR   = File.expand_path("build/dist/x86")
TEMPLATE_DIR         = File.expand_path("template")
TARGET_DIR           = File.expand_path("target")

task default: ["installer:latest"]

task :clean do
  rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
end

namespace :installer do
  task :latest do
    rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
    build_aipo
    build_aipo_opensocial
    installer_package
  end
  task :stable do
    rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
    build_aipo(branch: "#{STABLE_BRANCH}")
    build_aipo_opensocial(branch: "#{STABLE_BRANCH}")
    installer_package(version: "#{STABLE_VERSION}", version_short: "#{STABLE_VERSION_SHORT}")
  end
end

def build_aipo(branch: "#{LATEST_BRANCH}")
  sh %[mkdir -p "#{BUILD_DIR}"]
  sh %[(cd #{BUILD_DIR}; git clone -b #{branch} https://github.com/aipocom/aipo.git)]
  sh %[(cd #{BUILD_DIR}/aipo; mvn clean; mvn install)]
end

def build_aipo_opensocial(branch: "#{LATEST_BRANCH}")
  sh %[mkdir -p "#{BUILD_DIR}"]
  sh %[(cd #{BUILD_DIR}; git clone -b #{branch} https://github.com/aipocom/aipo-opensocial.git)]
  sh %[(cd #{BUILD_DIR}/aipo-opensocial; mvn clean; mvn install)]
end

def installer_package(version: "#{LATEST_VERSION}", version_short: "#{LATEST_VERSION_SHORT}")
  dist_x86_dirname = "aipo-#{version_short}-linux-x86"
  dist_x64_dirname = "aipo-#{version_short}-linux-x64"
  sh %[mkdir -p "#{TARGET_DIR}"]
  sh %[mkdir -p "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}"]
  sh %[mkdir -p "#{BUILD_DIST_X64_DIR}/#{dist_x64_dirname}"]
  sh %[mkdir -p "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist/sql"]
  sh %[mkdir -p "#{BUILD_DIST_X64_DIR}/#{dist_x64_dirname}/dist/sql"]

  FileUtils.cp("#{BUILD_DIR}/aipo/war/target/aipo.war", "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist")
  FileUtils.cp("#{BUILD_DIR}/aipo-opensocial/war/target/container.war", "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist")
  FileUtils.cp_r(FileList["#{BUILD_DIR}/aipo/sql/postgres/*"], "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist/sql")
  sh %[(cd #{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist; curl -LO 'http://ftp.riken.jp/net/apache/tomcat/tomcat-7/v7.0.59/bin/apache-tomcat-7.0.59.tar.gz')]
  sh %[(cd #{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist; curl -LO 'https://ftp.postgresql.org/pub/source/v9.3.6/postgresql-9.3.6.tar.gz')]
  sh %[(cd #{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist; curl -LO 'https://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc41.jar')]
  FileUtils.cp_r(FileList["#{TEMPLATE_DIR}/*"], "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}")
  FileUtils.sed("#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/bin/install.conf", /AIPO_VERSION=(.*)/, "AIPO_VERSION=#{version}")

 FileUtils.cp_r(FileList["#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist/*"], "#{BUILD_DIST_X64_DIR}/#{dist_x64_dirname}/dist")
  sh %[(cd #{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist; curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u40-b25/jre-8u40-linux-i586.tar.gz' -H 'Cookie: oraclelicense=accept-securebackup-cookie')]
  sh %[(cd #{BUILD_DIST_X64_DIR}/#{dist_x64_dirname}/dist; curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u40-b25/jre-8u40-linux-x64.tar.gz' -H 'Cookie: oraclelicense=accept-securebackup-cookie')]
  FileUtils.sed("#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/bin/install.conf", /x64/, "i586")

  sh %[rm -rf "#{TARGET_DIR}/#{dist_x86_dirname}.tar.gz"]
  sh %[(cd #{BUILD_DIST_X86_DIR}; tar cvzf #{TARGET_DIR}/#{dist_x86_dirname}.tar.gz --owner=root --group=root --exclude ".git" --exclude "*x64.tar.gz" #{dist_x86_dirname})]
  sh %[rm -rf "#{TARGET_DIR}/#{dist_x64_dirname}.tar.gz"]
  sh %[(cd #{BUILD_DIST_X64_DIR}; tar cvzf #{TARGET_DIR}/#{dist_x64_dirname}.tar.gz --owner=root --group=root --exclude ".git" --exclude "*i586.tar.gz" #{dist_x64_dirname})]
end

module FileUtils
  def self.sed(file, pattern, replacement)
    File.open(file, "r") do |f_in|
      buf = f_in.read
      buf.gsub!(pattern, replacement)
      File.open(file, "w") do |f_out|
        f_out.write(buf)
      end
    end
  end
end
