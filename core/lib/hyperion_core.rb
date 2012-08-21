module Hyperion
  class Core

    class << self

      attr_writer :datastore

      def datastore
        @datastore ||= raise "No Datastore Installed"
      end

      def new?(record)
        record.has_key?(:id)
      end

    #  def save(record, attrs={})
    #    datastore.save([record.merge(attrs)]).first
    #  end

    #  def save_all(records)
    #    datastore.save(records)
    #  end

    #  def find_by_id(kind, id)
    #    datastore.find_by_kind(kind, id)
    #  end

    #  def reload(record)
    #    datastore.find_by_id(record[:kind], record[:id])
    #  end

    #  def find_by_kind(kind, args={})
    #  end

    #  def find_all_kinds(args={})
    #  end

    #  def count_by_kind(kind, args={})
    #  end

    #  def count_all_kinds(args={})
    #  end

    #  def delete_by_id(kind, id)
    #  end

    #  def delete_by_kind(kind, args={})
    #  end

    end
  end
end
