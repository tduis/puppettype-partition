Puppet::Type.newtype(:partition) do
  #
  # parted -a optimal --script /dev/sdb 'mkpart primary ext4 1 100%'
  #
  #  mklabel label-type
  #  Create a new disklabel (partition table) of label-type.  label-type should be one  of
  #  "aix", "amiga", "bsd", "dvh", "gpt", "loop", "mac", "msdos", "pc98", or "sun".
  #
  #  mkpart part-type [fs-type] start end
  #  Make  a part-type partition for filesystem fs-type (if specified), beginning at start
  #  "ext3", "ext4", "fat16", "fat32", "hfs", "hfs+", "linux-swap", "ntfs", "reiserfs", or
  #  "xfs".  part-type should be one of "primary", "logical", or "extended".
  desc 'The partition type is used to create partitions on disk devices'

  # Make sure we can  use present and absent for this type
  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the partition (eg:  /dev/sdb1)'
    validate do |value|
      fail("Invalide device #{value}") unless value =~ /^\/dev\/s[a-z][a-z][0-9]$/
    end
  end

  newparam(:alignment) do
    desc 'The alignment of the partition: none,cylinder,minimal or optimal (defaultto optimal)'
    defaultto :optimal
    newvalues(:none, :cylinder, :minimal, :optimal)
  end

  newparam(:p_begin) do
    desc 'The beginning of the disk, default=1'
    defaultto :'1'
  end

  newparam(:p_end) do
    desc 'The end of the disk eg: 10GB, 100%'
    defaultto :'100%'
  end


  newparam(:part_label) do
    desc 'The partition label (eg. msdos,aix,amiga,bsd,dvh,gpt,loop,mac,pc98 or sun)'
    defaultto :msdos
    newvalues(:msdos,:aix,:amiga,:bsd,:dvh,:gpt,:loop,:mac,:pc98,:sun)
  end

  newproperty(:part_type) do
    desc 'The partition type (eg. primary,logical or extended)'
    defaultto :primary
    newvalues(:primary,:logical,:extended)
  end

  newparam(:fs_type) do
    desc 'The filesystem for this partition (eg, ext2,ext3,ext4,btrfs,xfs,fat16, fact32,hfs,hfs+,linux-swap) see comments above or man parted for more.' 
    defaultto :ext4
    newvalues(:ext2,:ext3,:ext4,:btrfs,:xfs,:fat16,:fat32,:hfs,:'hfs+',:'linux-swap')
  end

end
