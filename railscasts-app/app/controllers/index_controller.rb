class IndexController < ApplicationController

    def index
        @episodes = Episode.all
        @tags = Tag.order(:tag)
        filter = process_filter
        search = process_search
        logger.info filter
        @episodes = @episodes.pro     if filter.include? "pro"
        @episodes = @episodes.revised if filter.include? "revised"
        @episodes = @episodes.free    if filter.include? "free"
        @episodes = @episodes.text_search(search) if search

        @episodes = @episodes.order("number desc, revised desc").includes(:tags).to_a

        filter.each do |tag|
            t = Tag.find_by(tag: tag)
            @episodes.select! { |ep| ep.tags.include? t } if t
        end
    end

    def show
        @episode = Episode.find params[:id]
        set_title
    end

    def show_ep
        number = params[:number]
        revised = (params[:revised] == 'revised')

        @episode = Episode.find_by(number: number, revised: revised)
        set_title
        render :show
    end

    private

    def process_filter
        if !params[:filter] or !params[:filter].is_a? Array
            []
        else
            params[:filter]
        end
    end

    def process_search
        if !params[:search] || params[:search].empty?
            nil
        else
            params[:search]
        end
    end

    def set_title
        @title = @episode.number.to_s
        @title += " revised" if @episode.revised
        @title += " - " + @episode.name
    end

end
