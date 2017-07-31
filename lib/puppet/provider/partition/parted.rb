Puppet::Type.type(:partition).provide(:parted) do
  confine :kernel =>  :linux

  # There are the commands we use in this type
  commands :parted => 'parted',
           :fdisk  => 'fdisk'


  # This is needed to make sure we can use the puppet resource partition /dev/sdb1
  # in order to let puppet describe an existing partition to use in pp file.
  # fdisk -l|grep '^\/dev\/sd[a-zA-Z][0-9]'
  # output:
  #   /dev/sda1   *        2048     1026047      512000   83  Linux
  #   /dev/sdb1            2048    16777215     8387584   83  Linux
  def self.instances
    partitions = fdisk('-l')
    partitions=partitions.split("\n").grep("^\/dev\/sd[a-zA-Z][0-9]").collect do |line|
      name = line.split(' ')
      part_type = 'primary'
      # initializes @property_hasg
      new( :name => name,
          :ensure => :present,
          :part_type => part_type,
      )
    end
  end

  # Getter for part_type
  def part_type
    partition= resource[:name]
    device=partition[0,(partition.length-1)]
    partition_nr=partition.slice(partition.length - 1)
    case partition_nr.to_i
      when 1 then 
        part_type='primary'
        $1
      when 2 then 
        part_type='primary'
        $1
      when 3 then 
        part_type='primary'
        $1
      when 4 then 
        part_type='primary'
        $1
      when 5 then 
        part_type='extended'
        $1
      when 6 .. 100 then 
        part_type='logical'
        $1
      else
        raise Puppet::Error, "Puppet roulette failed, no catalog for you!"
        #part_type='onbekend'
        #$1
    end
  end


  # Setter for part_type (not used)
  def part_type=(value)

  end

  # The check for presence of the partition 
  def exists?
    begin
      partition= resource[:name]
      device=partition[0,(partition.length-1)]
      if File.exist?(partition)
        true
      else
        false
      end
    end
  end

  # Creating partition
  # command: parted -a optimal --script /dev/sdb mklabel msdos mkpart primary ext4 1 100%'
  def create
    begin
      # Set the partition (/dev/sdb1), device (/dev/sdb) and alignment (optimal,minimal,none etc.) variables
      partition= resource[:name]
      device=partition[0,(partition.length-1)]
      alignment= resource[:alignment]

      # Now we can create the partition
      partitions = parted('-a', resource[:alignment],'--script',device,'mklabel',resource[:part_label],'mkpart',  resource[:part_type],resource[:fs_type],resource[:p_begin],resource[:p_end])
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  # Remove and existing partition
  # parted --script /dev/sdb rm 1
  def destroy
    begin
      # We need to set some variables, but we NEED the partition number to delete the partition
      partition= resource[:name]
      device=partition[0,(partition.length-1)]
      partition_nr=partition.slice(partition.length - 1)
      parted('--script',device,'rm',partition_nr)
    rescue Puppet::ExecutionFailure => e
      false
    end
  end


end
