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
STABLE_BRANCH        = "v8.1"
NOW                  =  DateTime.now.strftime("%Y%m%d")
LATEST_VERSION       = "latest-#{NOW}"
LATEST_VERSION_SHORT = "latest-#{NOW}"
STABLE_VERSION       = "8.1.0.0"
STABLE_VERSION_SHORT = "8.1.0"

BUILD_DIR            = File.expand_path("build")
BUILD_DIST_DIR       = File.expand_path("build/dist")
BUILD_DIST_X64_DIR   = File.expand_path("build/dist/x64")
BUILD_DIST_X86_DIR   = File.expand_path("build/dist/x86")
TEMPLATE_DIR         = File.expand_path("template")
TARGET_DIR           = File.expand_path("target")

# repository
AIPO_REPO = ENV['AIPO_REPO'] || 'https://github.com/aipocom/aipo.git'
AIPO_OPENSOCIAL_REPO = ENV['AIPO_OPENSOCIAL_REPO'] || 'https://github.com/aipocom/aipo-opensocial.git' 

# use local dir
LOCAL = ENV['LOCAL'] || false
AIPO_REPO_DIR = ENV['AIPO_REPO_DIR']
AIPO_OPENSOCIAL_REPO_DIR = ENV['AIPO_OPENSOCIAL_REPO_DIR']

task default: ["installer:latest"]

task :clean do
  rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
end

namespace :all do
  desc "build all for stable"
  task :stable do
    rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
    build_aipo(branch: "#{STABLE_BRANCH}")
    build_aipo_opensocial(branch: "#{STABLE_BRANCH}")
    installer_package(version: "#{STABLE_VERSION}", version_short: "#{STABLE_VERSION_SHORT}", prefix: "#{STABLE_VERSION_SHORT}")
    installer_package(version: "#{STABLE_VERSION}", version_short: "#{STABLE_VERSION_SHORT}", prefix: "update7.0.2to8.0.1", script: "update7020to8010.sh", target_version: "7.0.2")
    installer_package(version: "#{STABLE_VERSION}", version_short: "#{STABLE_VERSION_SHORT}", prefix: "update8.0to8.0.1", script: "update8000to8010.sh", target_version: "8.0", middleware: false)
    installer_package(version: "#{STABLE_VERSION}", version_short: "#{STABLE_VERSION_SHORT}", prefix: "update8.0.1to8.1", script: "update8010to8100.sh", target_version: "8.0.1")
  end
end

namespace :installer do
  desc "build installer for latest"
  task :latest do
    rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
    build_aipo
    build_aipo_opensocial
    installer_package
  end
  desc "build installer for stable"
  task :stable do
    rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
    build_aipo(branch: "#{STABLE_BRANCH}")
    build_aipo_opensocial(branch: "#{STABLE_BRANCH}")
    installer_package(version: "#{STABLE_VERSION}", version_short: "#{STABLE_VERSION_SHORT}", prefix: "#{STABLE_VERSION_SHORT}")
  end
end

namespace :updater do
  desc "build updater for 7.0.2 to 8.0.1"
  task :"7020to8010" do
    rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
    build_aipo(branch: "#{STABLE_BRANCH}")
    build_aipo_opensocial(branch: "#{STABLE_BRANCH}")
    installer_package(version: "#{STABLE_VERSION}", version_short: "#{STABLE_VERSION_SHORT}", prefix: "update7.0.2to8.0.1", script: "update7020to8010.sh", target_version: "7.0.2")
  end
  desc "build updater for 8.0.0 to 8.0.1"
  task :"8000to8010" do
    rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
    build_aipo(branch: "#{STABLE_BRANCH}")
    build_aipo_opensocial(branch: "#{STABLE_BRANCH}")
    installer_package(version: "#{STABLE_VERSION}", version_short: "#{STABLE_VERSION_SHORT}", prefix: "update8.0to8.0.1", script: "update8000to8010.sh", target_version: "8.0", middleware: false)
  end
  desc "build updater for 8.0.1 to 8.1.0"
  task :"8010to8100" do
    rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
    build_aipo(branch: "#{STABLE_BRANCH}")
    build_aipo_opensocial(branch: "#{STABLE_BRANCH}")
    installer_package(version: "#{STABLE_VERSION}", version_short: "#{STABLE_VERSION_SHORT}", prefix: "update8.0.1to8.1", script: "update8010to8100.sh", target_version: "8.0.1")
  end
end

def build_aipo(branch: "#{LATEST_BRANCH}")
  sh %[mkdir -p "#{BUILD_DIR}"]
  if LOCAL then
    sh %[(cp -R #{AIPO_REPO_DIR} #{BUILD_DIR}/aipo)]
  else
    sh %[(cd #{BUILD_DIR}; git clone -b #{branch} #{AIPO_REPO})]
  end
  sh %[(cd #{BUILD_DIR}/aipo; mvn clean; mvn install)]
end

def build_aipo_opensocial(branch: "#{LATEST_BRANCH}")
  sh %[mkdir -p "#{BUILD_DIR}"]
  if LOCAL then
    sh %[(cp -R #{AIPO_OPENSOCIAL_REPO_DIR} #{BUILD_DIR}/aipo-opensocial)]
  else
    sh %[(cd #{BUILD_DIR}; git clone -b #{branch} #{AIPO_OPENSOCIAL_REPO})]
  end
  sh %[(cd #{BUILD_DIR}/aipo-opensocial; mvn clean; mvn install)]
end

def installer_package(version: "#{LATEST_VERSION}", version_short: "#{LATEST_VERSION_SHORT}", prefix: "#{LATEST_VERSION_SHORT}", script: "installer.sh", target_version: "", middleware: true)
  dist_x86_dirname = "aipo-#{prefix}-linux-x86"
  dist_x64_dirname = "aipo-#{prefix}-linux-x64"
  sh %[mkdir -p "#{TARGET_DIR}"]
  sh %[mkdir -p "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}"]
  sh %[mkdir -p "#{BUILD_DIST_X64_DIR}/#{dist_x64_dirname}"]
  sh %[mkdir -p "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist/sql"]
  sh %[mkdir -p "#{BUILD_DIST_X64_DIR}/#{dist_x64_dirname}/dist/sql"]
  sh %[mkdir -p "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/bin"]
  sh %[mkdir -p "#{BUILD_DIST_X64_DIR}/#{dist_x64_dirname}/bin"]

  FileUtils.cp("#{BUILD_DIR}/aipo/war/target/aipo.war", "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist")
  FileUtils.cp("#{BUILD_DIR}/aipo-opensocial/war/target/container.war", "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist")
  FileUtils.cp_r(FileList["#{BUILD_DIR}/aipo/sql/postgres/*"], "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist/sql")
  if middleware then
  sh %[(cd #{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist; curl -LO 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.67/bin/apache-tomcat-7.0.67.tar.gz')]
  sh %[(cd #{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist; curl -LO 'https://ftp.postgresql.org/pub/source/v9.3.10/postgresql-9.3.10.tar.gz')]
  sh %[(cd #{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist; curl -LO 'https://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc41.jar')]
  end
  FileUtils.cp_r(FileList["#{TEMPLATE_DIR}/dist/*"], "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist")
  FileUtils.cp_r(FileList["#{TEMPLATE_DIR}/bin/*"], "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/bin")
  FileUtils.cp_r(FileList["#{TEMPLATE_DIR}/#{script}"], "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/")

  if "#{script}" == "installer.sh" then
    FileUtils.cp(FileList["#{TEMPLATE_DIR}/readme_install.txt"], "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/")
    sh %[mv "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/readme_install.txt" "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/readme.txt"]
  else
    FileUtils.cp_r(FileList["#{TEMPLATE_DIR}/readme_update.txt"], "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/")
    sh %[mv "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/readme_update.txt" "#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/readme.txt"]
  end
  FileUtils.sed("#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/readme.txt", /{AIPO_VERSION_SHORT}/, "#{version_short}")
  FileUtils.sed("#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/readme.txt", /{SCRIPT}/, "#{script}")
  FileUtils.sed("#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/readme.txt", /{TARGET_VERSION}/, "#{target_version}")

  FileUtils.sed("#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/bin/install.conf", /AIPO_VERSION=(.*)/, "AIPO_VERSION=#{version}")

  FileUtils.cp_r(FileList["#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/*"], "#{BUILD_DIST_X64_DIR}/#{dist_x64_dirname}/")

  if middleware then
  sh %[(cd #{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/dist; curl -LO 'https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jre-8u202-linux-i586.tar.gz' -H 'Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cook')]
  sh %[(cd #{BUILD_DIST_X64_DIR}/#{dist_x64_dirname}/dist; curl -LO 'https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jre-8u202-linux-x64.tar.gz' -H 'Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cook')]
  end
  FileUtils.sed("#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/bin/install.conf", /x64/, "i586")
  FileUtils.sed("#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/bin/install.conf", /LONG_BIT=64/, "LONG_BIT=32")
  FileUtils.sed("#{BUILD_DIST_X86_DIR}/#{dist_x86_dirname}/readme.txt", /{DIST_DIRNAME}/, "#{dist_x86_dirname}")
  FileUtils.sed("#{BUILD_DIST_X64_DIR}/#{dist_x64_dirname}/readme.txt", /{DIST_DIRNAME}/, "#{dist_x64_dirname}")

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
