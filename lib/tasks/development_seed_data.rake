# frozen_string_literal: true

namespace :development do
  namespace :db do
    desc "Seed development data"
    task seed: :environment do
      seed_star_trek_articles
    end
  end
end

def seed_star_trek_articles
  Current.bucket = Bucket.find_or_create_by!(name: "Default")
  Current.user = User.find_or_create_by!(email_address: "dave@makoo.com")

  articles_data = [
    {
      title: "The Prime Directive: Starfleet's Most Debated Policy",
      body: <<~BODY
        The Prime Directive, also known as Starfleet General Order 1, stands as the most fundamental guiding principle of the United Federation of Planets. It prohibits Starfleet personnel from interfering with the natural development of alien civilizations, particularly those that have not yet developed warp drive technology.

        Throughout the centuries of space exploration, captains have faced agonizing decisions when the Prime Directive conflicts with their moral compass. Captain Kirk famously bent this rule on numerous occasions, arguing that allowing suffering when you have the power to prevent it is itself a form of interference. Captain Picard, in contrast, often upheld the directive even when it meant watching civilizations face extinction.

        The philosophical debate continues: Is non-interference truly neutral, or does the act of observation itself constitute a form of contact? As the Federation expands and encounters ever more diverse forms of life, the Prime Directive remains both a shield against cultural imperialism and a source of profound ethical tension.
      BODY
    },
    {
      title: "Warp Drive Theory: How It Works",
      body: <<~BODY
        Warp drive technology revolutionized space travel by allowing vessels to exceed the speed of light without violating the laws of physics. Rather than accelerating through space, a warp-capable vessel creates a subspace bubble that contracts space ahead and expands it behind, effectively moving the fabric of spacetime itself.

        The key to this technology lies in the matter-antimatter reaction chamber, where deuterium and antideuterium are combined under carefully controlled conditions. This reaction is mediated by dilithium crystals, which have the unique property of being non-reactive to antimatter when subjected to high-frequency electromagnetic fields. The resulting energy is channeled through plasma conduits to the warp nacelles.

        Warp speeds are measured on a logarithmic scale, with Warp 1 representing the speed of light and each subsequent factor representing an exponential increase. The theoretical limit of Warp 10 represents infinite velocity—occupying all points in the universe simultaneously—and has been achieved only once under extraordinary circumstances with disturbing biological side effects.
      BODY
    },
    {
      title: "The Borg: Collective Consciousness Explained",
      body: <<~BODY
        The Borg Collective represents one of the most terrifying and fascinating phenomena in the known galaxy. This cybernetic civilization operates as a single hive mind, with trillions of drones connected through a subspace network that allows instantaneous communication across vast distances. Individual consciousness is suppressed, replaced by the unified will of the Collective.

        Assimilation—the process by which the Borg absorb other species—begins with the injection of nanoprobes that rapidly replicate and begin converting biological tissue into cybernetic components. Within hours, the victim's neural pathways are rewired to connect with the Collective, and their individual identity is subsumed into the whole. The Borg view this not as conquest but as a gift, elevating species toward what they consider perfection.

        The Collective's greatest strength is also its vulnerability. The hive mind allows for perfect coordination but creates a single point of failure. Individuals who have been severed from the Collective, such as Seven of Nine, demonstrate that the assimilated can be recovered, though the psychological trauma of disconnection presents its own challenges.
      BODY
    },
    {
      title: "Captain Kirk vs Captain Picard: Leadership Styles",
      body: <<~BODY
        James T. Kirk and Jean-Luc Picard represent two distinct eras of Starfleet command, each embodying the values and challenges of their time. Kirk, commanding the original Enterprise during the frontier days of exploration, led with intuition, charisma, and a willingness to take bold risks. He trusted his gut, often defied regulations, and wasn't afraid to throw a punch when diplomacy failed.

        Picard, by contrast, exemplified the more refined Federation of the 24th century. A diplomat, archaeologist, and philosopher, he approached conflicts with patience and reason. Where Kirk might beam down with a landing party and phasers ready, Picard would convene a conference and seek understanding. His leadership was consultative, regularly seeking input from his senior staff before making decisions.

        Neither approach is superior—each captain was perfectly suited to their era. Kirk's boldness was essential when the Federation was young and threats were immediate. Picard's measured diplomacy reflected a more established civilization navigating complex political relationships. Together, they demonstrate that great leadership adapts to circumstance while remaining true to core principles.
      BODY
    },
    {
      title: "Vulcan Logic: Philosophy and Practice",
      body: <<~BODY
        Vulcan philosophy emerged from a violent past. Before the Time of Awakening, Vulcans were a passionate, warlike people whose emotions frequently led to devastating conflicts. The philosopher Surak proposed a radical alternative: the complete suppression of emotion in favor of pure logic. This teaching, known as cthia, transformed Vulcan civilization and eventually enabled them to become founding members of the Federation.

        The practice of logic extends beyond mere rational thinking. Vulcans undergo rigorous mental training from childhood, learning techniques like meditation and mind-melding to control their still-powerful emotions. The kolinahr ritual represents the ultimate achievement—the complete purging of all remaining emotion. However, few Vulcans complete this arduous process, and many question whether complete emotional suppression is truly logical.

        Critics, including some Vulcans, argue that the philosophy is fundamentally dishonest. Vulcans do not lack emotions; they simply refuse to acknowledge them. This repression can lead to psychological difficulties, particularly during pon farr, the mating cycle that temporarily overwhelms logical control. The balance between logic and emotion remains a subject of ongoing philosophical debate on Vulcan.
      BODY
    },
    {
      title: "Deep Space Nine: The Station That Changed Everything",
      body: <<~BODY
        Deep Space Nine began as a Cardassian mining station orbiting Bajor, built through the forced labor of Bajoran prisoners during the brutal Occupation. When the Cardassians withdrew, the Federation assumed joint administration with the newly independent Bajoran government. What seemed like a backwater assignment became the most strategically important posting in the quadrant with the discovery of the Bajoran wormhole.

        Unlike starships that could leave troubled situations behind, Deep Space Nine was stationary. Its crew had to live with the consequences of their decisions, building lasting relationships with recurring characters—Bajoran officials, Ferengi merchants, visiting dignitaries. This permanence allowed for deeper exploration of consequences, politics, and moral ambiguity than the episodic nature of other series permitted.

        The station became the focal point of the Dominion War, the largest conflict the Federation had ever faced. The serialized storytelling that emerged broke new ground for Star Trek, showing the true costs of war: compromised principles, lost lives, and the difficult work of rebuilding. Deep Space Nine proved that Star Trek could tackle darker themes while remaining true to its optimistic vision of the future.
      BODY
    },
    {
      title: "The Holodeck: Entertainment or Danger?",
      body: <<~BODY
        Holographic technology represents one of the most impressive achievements of Federation engineering. By combining replicated matter with sophisticated force fields and photonic projections, holodecks can create environments virtually indistinguishable from reality. Users can explore historical periods, fictional worlds, or custom scenarios limited only by imagination and available computer memory.

        However, the holodeck's safety record raises serious concerns. Malfunctions have repeatedly endangered crew members, from deactivated safety protocols to sentient holographic characters attempting to escape their programmed existence. The Enterprise-D alone experienced dozens of holodeck-related emergencies, leading some to question why such a dangerous technology remains standard equipment on Federation vessels.

        Beyond safety, holodecks raise profound psychological and ethical questions. Addiction to holographic experiences has been documented, with users preferring simulated relationships to real ones. The creation of sentient holograms like the Doctor on Voyager challenges assumptions about consciousness and rights. As holographic technology advances, the line between simulation and reality grows increasingly blurred.
      BODY
    },
    {
      title: "Klingon Honor: A Warrior's Code",
      body: <<~BODY
        Honor forms the foundation of Klingon society, governing everything from personal conduct to imperial politics. A Klingon's honor is not merely individual but extends to their entire House—a noble lineage that can span centuries. Actions that bring dishonor can taint a family for generations, while glorious deeds in battle can elevate a House to greatness.

        The warrior ethos permeates Klingon culture. Combat is not merely tolerated but celebrated as the highest expression of Klingon values. Death in battle guarantees entry to Sto-vo-kor, the afterlife reserved for the honored dead, while dying of old age or illness is considered shameful. This philosophy extends to their rituals, cuisine, and even their opera, which recounts the legendary battles of Kahless the Unforgettable.

        Yet Klingon honor is more nuanced than simple bloodlust. True honor requires keeping one's word, protecting the weak, and standing against injustice even when outnumbered. The greatest Klingon heroes are not merely skilled fighters but principled warriors who chose death over dishonor. As the Empire's alliance with the Federation deepened, many Klingons found new ways to express honor through diplomacy, science, and service.
      BODY
    },
    {
      title: "Q Continuum: Omnipotence and Morality",
      body: <<~BODY
        The Q Continuum exists outside normal spacetime, inhabited by beings of nearly unlimited power. A single Q can alter the fabric of reality, create or destroy entire species, and travel instantly across the universe or through time. They have observed the development of countless civilizations, occasionally intervening in ways that range from beneficial to catastrophic.

        The entity known simply as Q took particular interest in humanity, putting the species on trial for the crimes of being a "dangerous, savage child race." His tests, while often appearing capricious, seemed designed to challenge human assumptions and push Starfleet officers toward growth. Whether Q genuinely cared about human development or simply found us amusing remains unclear—perhaps the distinction is meaningless to an omnipotent being.

        The Continuum itself is not without internal conflict. Some Q grew bored with eternal existence, while others debated the ethics of intervention in mortal affairs. A civil war among the Q nearly destroyed the fabric of subspace across multiple sectors. Even omnipotence, it seems, cannot resolve fundamental questions about meaning, purpose, and the responsibilities that come with unlimited power.
      BODY
    },
    {
      title: "The Mirror Universe: When Heroes Become Villains",
      body: <<~BODY
        The Mirror Universe exists as a parallel dimension where the moral compass points in the opposite direction. First discovered accidentally through a transporter malfunction, this alternate reality features brutal versions of familiar characters. The benevolent United Federation of Planets is replaced by the Terran Empire, an aggressive, conquest-driven regime where advancement comes through assassination and betrayal.

        The differences extend beyond politics to fundamental character. Mirror Spock, while still logical, serves an empire built on violence. Mirror Kira rose through the ranks of the Alliance through ruthlessness rather than resistance. These dark reflections raise uncomfortable questions about nature versus nurture—are our choices products of circumstance, or is there something essential about who we are?

        Crossover events between universes have had lasting consequences. The reforms mirror Spock implemented after meeting his prime counterpart led to the Empire's collapse and Terran enslavement by the Klingon-Cardassian Alliance. This suggests that even well-intentioned changes can have catastrophic unintended consequences—a lesson that applies equally to both universes.
      BODY
    }
  ]

  created_count = 0

  articles_data.each do |data|
    article = Article.find_or_create_by!(title: data[:title]) do |a|
      a.body = data[:body].strip
    end
    Recording.find_or_create_by!(recordable: article)
    created_count += 1 if article.previously_new_record?
  end

  puts "Created #{created_count} new Star Trek articles (#{articles_data.size - created_count} already existed)"
end
