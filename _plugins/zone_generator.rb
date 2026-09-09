require 'json'

module Jekyll
  class ZonePageGenerator < Generator
    safe true
    priority :normal

    def generate(site)
      items = load_json(site, '_rawdata/zone.json')

      Jekyll.logger.info "ZoneGenerator:", "#{items.size}개 어린이보호구역 페이지 생성 중..."
      items.each do |z|
        next if z['slug'].to_s.strip.empty?
        site.pages << ZonePage.new(site, z)
      end

      Jekyll.logger.info "ZoneGenerator:", "완료 (#{items.size}개)"
    end

    private

    def load_json(site, path)
      file = File.join(site.source, path)
      return [] unless File.exist?(file)
      JSON.parse(File.read(file, encoding: 'utf-8'))
    rescue => e
      Jekyll.logger.warn "ZoneGenerator:", "#{path} 로드 실패: #{e.message}"
      []
    end
  end

  class ZonePage < Page
    def initialize(site, z)
      @site = site
      @base = site.source
      @dir  = "zone/#{z['slug']}"
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(@base, '_layouts'), 'zone.html')
      self.data.merge!(z)
      self.data['layout']      = 'zone'
      self.data['title']       = build_title(z)
      self.data['description'] = build_desc(z)
    end

    private

    def build_title(z)
      loc = [z['doShort'], z['sigungu']].compact.join(' ')
      "#{z['zoneName']} 어린이보호구역 #{loc} 위치·CCTV 안내"
    end

    def build_desc(z)
      loc = [z['doShort'], z['sigungu']].compact.join(' ')
      cctv = z['cctvYn'] == 'Y' ? "CCTV #{z['cctvCount']}대 설치" : 'CCTV 정보 확인'
      "#{loc} #{z['zoneName']} 어린이보호구역(#{z['kind']}). #{cctv}. 관할: #{z['policeStation']}"[0, 155]
    end
  end
end
