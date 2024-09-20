# frozen_string_literal: true

namespace :gitlab do
  namespace :praefect do
    def int?(string)
      true if Integer(string)
    rescue StandardError
      false
    end

    def print_single_project_checksums(hash)
      header = []
      row_elements = []
      hash.each do |key, value|
        width = [key.length, value.length].max
        header << key.ljust(width) unless header.include?(key)
        row_elements << value.ljust(width)
      end
      header_str = header.join(' | ')
      puts header_str
      puts '-' * header_str.length
      puts row_elements.join(' | ')
      puts '-' * header_str.length
    end

    def get_replicas_checksum(project)
      begin
        replicas_resp = project.repository.replicas
      rescue Gitlab::Git::CommandError
        return { "Project name" => project.name }
      end

      sorted_replicas = replicas_resp.replicas.sort_by { |r| r.repository.storage_name }

      checksum_hash = {
        'Project name' => project.name,
        replicas_resp.primary.repository.storage_name => "#{replicas_resp.primary.checksum} (primary)"
      }
      checksum_hash.merge(Hash[sorted_replicas.map do |r|
                                 r.repository.storage_name
                               end.zip(sorted_replicas.map do |r|
                                         r.checksum
                                       end)]).sort.to_h
    end

    desc 'GitLab | Praefect | Check replicas'
    task :replicas, [:project_id] => :gitlab_environment do |t, args|
      warn_user_is_not_gitlab

      if args.project_id.present?

        unless int?(args.project_id)
          puts 'argument must be a valid project_id'
          next
        end

        project = Project.find_by_id(args.project_id)

        if project.nil?

          puts 'No project was found with that id'
          next
        end

        begin
          checksum_hash = get_replicas_checksum(project)
        rescue StandardError
          puts 'Something went wrong when getting replicas.'
          next
        end

        puts "\n"

        print_single_project_checksums(checksum_hash)
      else
        width = 50
        checksums = Hash.new { |hash, key| hash[key] = [] }
        no_replicas = "No Replicas"

        Project.find_each(batch_size: 100) do |project|
          project_checksum = get_replicas_checksum(project)

          project_checksum.each do |key, value|
            checksums[key] << value
          end
        end
        width = checksums.values.max_by { |k, v| v.length }.max_by { |v| v.length }.length
        max_nodes = checksums.values.max_by { |a| a }.length
        project_name_width = checksums["Project name"].max_by { |v| v.length }.length

        m = checksums.values.map do |a|
          a + ([no_replicas] * (max_nodes - a.length))
        end.transpose.insert(0, checksums.keys)

        project_column = true
        m.each do |r|
          r.map do |x|
            print "#{project_column ? x.ljust(project_name_width) : x.ljust(width)} | "
            project_column = false
          end.inspect
          project_column = true
          puts
          puts '-' * (((checksums.keys.count - 1) * width) + project_name_width + 7)
        end

      end
    end
  end
end
