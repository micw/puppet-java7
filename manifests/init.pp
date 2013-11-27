# Class: oracle-java::java
#
# This module manages Oracle Java 6,7,8
# Parameters: none
# Requires:
#  apt
# Sample Usage:
# include oracle-java::java6
# include oracle-java::java7
# include oracle-java::java8

class oracle-java::java6 {
  oracle-java { "oracle-java6": javaVersion=>6 }
}
class oracle-java::java7 {
  oracle-java { "oracle-java7": javaVersion=>7 }
}
class oracle-java::java8 {
  oracle-java { "oracle-java8": javaVersion=>8 }
}

class oracle-java::java6-install-startcom-certs {
  require oracle-java::java6
  
  oracle-java::java-install-cert { "oracle-java6-startcom-certs.ca":
    certName=> "startcom.ca",
    jdkHome=>"/usr/lib/jvm/java-6-oracle"
  }
  oracle-java::java-install-cert { "oracle-java6-startcom-certs.class1":
    certName=> "startcom.ca.sub.class1",
    jdkHome=>"/usr/lib/jvm/java-6-oracle"
  }
  oracle-java::java-install-cert { "oracle-java6-startcom-certs.class2":
    certName=> "startcom.ca.sub.class2",
    jdkHome=>"/usr/lib/jvm/java-6-oracle"
  }
  oracle-java::java-install-cert { "oracle-java6-startcom-certs.class3":
    certName=> "startcom.ca.sub.class3",
    jdkHome=>"/usr/lib/jvm/java-6-oracle"
  }
  oracle-java::java-install-cert { "oracle-java6-startcom-certs.class4":
    certName=> "startcom.ca.sub.class4",
    jdkHome=>"/usr/lib/jvm/java-6-oracle"
  }
}

define oracle-java::java-install-cert ($ensure=present,
                                       $certName,
                                       $jdkHome='${JAVA_HOME}',
                                       $storepass='changeit') {
  $keytool="${jdkHome}/jre/bin/keytool"
  $keystore="${jdkHome}/jre/lib/security/cacerts"
  $certFileName="${certName}.crt"
  $certFile="/tmp/java_cert_${certFileName}"

  case $ensure {
    present: {
      file { $certFile:
        source => "puppet:///modules/oracle-java/ca/$certFileName",
        mode   => '0600',
        backup => false,
      } ->
      exec {"Import ${certName} cert in ${keystore}":
        command => "${keytool} -importcert -alias ${certName} -file ${certFile} -keystore ${keystore} -storepass ${storepass} -noprompt -trustcacerts",
        unless  => "${keytool} -list -keystore ${keystore} -alias ${certName}",
      }
    }
    absent: {
      exec {"Remove ${certName} cert from ${keystore}":
        exec   => "${keytool} -delete -keystore ${keystore} -alias ${certName} -storepass ${storepass}",
        onlyif => "${keytool} -list -keystore ${keystore} -alias ${certName}",
      }
    }
  }
}


define oracle-java($javaVersion) {
  case $::operatingsystem {
    debian: {
      include apt
      
      apt::source { 'webupd8team': 
        location          => "http://ppa.launchpad.net/webupd8team/java/ubuntu",
        release           => "precise",
        repos             => "main",
        key               => "EEA14886",
        key_server        => "keyserver.ubuntu.com",
        include_src       => true
      }
      package { "oracle-java${javaVersion}-installer":
        responsefile => '/tmp/java.preseed',
        require      => [
                          Apt::Source['webupd8team'],
                          File['/tmp/java.preseed']
                        ],
      }
   }
   ubuntu: {
     include apt

      apt::ppa { 'ppa:webupd8team/java': }
      package { "oracle-java${javaVersion}-installer":
        responsefile => '/tmp/java.preseed',
        require      => [
                          Apt::Ppa['ppa:webupd8team/java'],
                          File['/tmp/java.preseed']
                        ],
      }
   }
   default: { notice "Unsupported operatingsystem ${::operatingsystem}" }
  }

  case $::operatingsystem {
    debian, ubuntu: {
      file { '/tmp/java.preseed':
        source => 'puppet:///modules/oracle-java/java.preseed',
        mode   => '0600',
        backup => false,
      }
    }
    default: { notice "Unsupported operatingsystem ${::operatingsystem}" }
  }
}
