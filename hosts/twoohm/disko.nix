{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/mmcblk0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "f2fs";
                mountpoint = "/";
                extraArgs = [
                  "-O"
                  "extra_attr,inode_checksum,sb_checksum,compression"
                ];
                mountOptions = [
                  "defaults"
                  "noatime"
                  "compress_algorithm=zstd"
                  "compress_chksum"
                  "atgc"
                  "gc_merge"
                ];
              };
            };
          };
        };
      };
    };
  };
}
