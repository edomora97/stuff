require 'awesome_print'

# Classe di un attore
class Actor
	# giorni in cui l'attore è stato scelto
	attr_accessor :days, :id
	# ritorna il numero di giorni dell'attore
	def numDays
		return @days.size
	end
	def initialize id
		@id = id
		@days = []
	end
end

# Seleziona un elemento casuale dall'elenco rispettando
# la priorità indicata
#
# Ritorna -1 se non c'è nessun elemento da selezionare
def randDistr(prob) 
	dom = prob.inject(:+)
	return -1 if dom == 0
	return -1 if prob.size == 0
	# genera un numero casuale nel dominio
	r = rand()*dom.to_f
	sum = prob[0]
	i = 0
	while sum < dom do
		return i if sum > r
		i += 1
		sum += prob[i]
	end
	return i
end

# Stapa la tabella delle disponibilità degli attori
def printTable actors, disp, numDays
	# calcola delle informazioni statische sui dati
	media = actors.inject(0.0) { |s, e| s += e.numDays } / actors.size
	dev = Math.sqrt(actors.inject(0.0) { |s, e| s += (e.numDays-media)**2 } / actors.size)
	min = actors.inject(100000) { |s, e| s = [s, e.numDays].min }
	max = actors.inject(0) { |s, e| s = [s, e.numDays].max }
	
	print "Media: #{media}\n"
	print "Deviazione: #{dev}\n"
	print "Minimo: #{min}\n"
	print "Massimo: #{max}\n"
	
	c = numDays
	r = actors.size

	# stampa le intestazioni della tabella
	print "  "
	c.times do |i|
		if i < 10
			print " #{i}"
		else
			print i
		end
	end
	print "\n"

	# stampa la tabella riga per riga
	r.times do |j|
		# stampa l'intastazione della colonna
		print " " if actors[j].id < 10
		print "#{actors[j].id}"
		
		# stampa le colonne della riga
		c.times do |i|
			# se l'attore non è disponibile in quel giorno
			if not disp[actors[j].id].include? i
				print "  "
			# se l'attore è stato scelto per il giorno
			elsif actors[j].days.include? i
				print " █"
			# se l'attore non è stato scelto
			else
				print " ."
			end
		end
		# stampa il numero di giorni in cui l'attore è stato scelto
		print "  <- #{actors[j].numDays}\n"
	end
end

def compute disp, days
	# memorizzo il numero di attori e di giorni
	numActors = disp.size
	numDays = days.size

	actors = []
	numActors.times { |id| actors << Actor.new(id) }
	
	# per ogni giorno fai il calcolo
	numDays.times do |i|
		# per ogni attore del giorno
		days[i].times do
			# probabilità da calcolare
			prob = []
			# calcola la probabilità di ogni attore
			numActors.times do |j|
				# se l'attore non è disponibile
				if not disp[j].include? i
					prob[j] = 0
				# se è già stato scelto
				elsif actors[j].days.include? i
					prob[j] = 0
				else
					prob[j] = 1 - Math.exp(-0.1/(0.0001+actors[j].numDays))
				end
			end
			
			# scelgo un attore a caso in base alle probabilità calcolate
			winner = randDistr prob
			# se non ci sono possibilità stop.
			break if winner == -1
			
			actors[winner].days << i
		end
	end
	puts "PRIMA PARTE: "
	printTable actors, disp, numDays
	
	# SECONDA PARTE: ottimizza
	actors.sort! { |x, y| x.numDays() <=> y.numDays() }
	
	# per ogni attore 
	numActors.times do |i|
		# trova tutte le corrispondenze probabilmente valide
		(numActors-1).downto(i+1) do |j|
			act1 = actors[i]
			act2 = actors[j]
			# se ha senso fare uno scambio
			if act2.numDays-act1.numDays>1
				# giorni non utilizzati di quello in difetto
				disp1 = disp[act1.id] - act1.days
				# giorni utilizzati di quello in eccesso
				disp2 = act2.days
				# giorni scambiabili
				common = disp1 & disp2
				
				# finche posso e ha senso scambiare
				while common.size>0 and act2.numDays-act1.numDays>1
					# giorno da scambiare
					d = common.last
					common.pop
					puts "Scambio #{d} da #{act2.id} a #{act1.id}"
					
					# effettua lo scambio
					actors[i].days.push d
					actors[j].days.delete d
				end
			end
		end
	end
	puts "\n\nSECONDA PARTE: "
	printTable actors, disp, numDays
	ap actors
	return actors
end

seed = rand 1000
srand(seed)
puts "SEED = #{seed}\n\n"

disp = [
	[1, 4, 6, 9],
	[0, 2, 4, 6, 10],
	[1, 3, 5, 8, 12],
	[0, 4, 7, 9, 10, 12],
	[2, 3, 5, 8, 11],
	[0, 2, 4, 7, 9, 11],
	[0, 1, 2, 3, 4],
	[0, 2, 5, 6, 9, 12],
	[1, 3, 7, 8, 10],
	[0, 3, 6, 9, 12],
	[0, 6, 11],
]
days = [1] * 13

compute disp, days
