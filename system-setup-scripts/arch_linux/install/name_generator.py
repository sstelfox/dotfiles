#!/usr/bin/env python

import random
import re
import subprocess

DESCRIPTORS = """
abandoned able abolished abrupt absolute acerbic aching aged ancient anxious
apetalous askew auspicious balanced bare bashful bawdy bewildered billowing
biting bitter blazing blocked bloody bold bound brash brave breathless briefest
bright bristling bubbling burning burnished cackling calibrated calming carnal
cerulean changing chaotic charred chilling civilized clean cleftal clever
clinging closed coarse collapsed comforting complacent condescending congealing
cool coquettish corndusted corrosive coruscant cosmic courteous coy cracked
crescent crimson crushed crystal curious daft dainty dangerous deep desperate
delicate demonic diligent dim distant divine dreadful dripping drunken dull
dusty dying echoing effortless effulgent elaborate elemental eloquent elusive
embarrassed emergent empty endless energized engraved enlightened envied ersatz
etched even exasperated exciting exiled explored faceted faint familiar fancy
faraway fast fathomless fearsome feathered feigned fierce finished fizzing
flagrant flickering floating flooded fond foolish foreign forgotten frail
frantic frayed free friendly frightened frosty fulsome furious furrowed gasping
gathered gentle giggling gilded gleaming glib glistening gloating glorious
glowing graceful grating graven greedy grubby guarded guilty halfseen healthy
heaving heavy hidden hoisted hollow hopeful horrid howling humming hurried
hushed icy idle immortal impious important improper indecent infernal innocent
intent intoxicating intractable inviolate invisible irritated isolated ivory
jagged javertian jittery jostled joyful just keening kindled kindly kinked
knowing lacking laden lank laughing lavender leathery level light liminal
lingible lithe lively loathe lonely looming lost loved lovely lurching
luxurious mad managed marvelous massive mauled meddling melting mended metal
mewling mighty mirrored missing misty moaning modest moonswept mortal motherly
moving muffled murmuring mysterious nameless narrow natural neat nefarious
nervous nestled newfound nonchalant normal numb obscured obvious odd offended
ominous oily oozing ordinary ornate overgrown padded painted pale panicked
passionate patient penultimate perfect perfumed pithy poisoned poor polished
plain planned playful pleasant pleased polished precious precise preserved
prickly prideful private prized profane proper proud pure puzzling quick quiet
quivering quotidian radiant ragged rakish rare rarified reasonable recovered
reflected refused relaxed reluctant replaced resting rediculous restless
ringing rippled rising roasted roiling rough rude ruined safe sanguine
satisfied scarce scarred scattered scintillant scraped screaming sealed
seasoned secret seemly seething selfish sensible shallow sharp shattered
shimmering shining shivering shuffling shy silent simple singing sinister
skewed slanting sleeping slick slow small smoky smooth smudged snarling soaked
soft solitary sooty sound sparkling spattered spiraling spiteful splintered
sprawling squeeking squirming staggering startled stately steaming steep stiff
still stirring stolid stormy strange striking strong stubborn sublime
sufficient suitable sullen sure supicious sweet swollen tangled tarnished
tattered tawdry tempered tender tenebrific terrible thieving threatening
tinkling tiny tired toasted toppled tumescent tremulant triumphant troublesome
truculent trusted tyrannical unassuming unbroken uncertain uncommon underground
unholy unexpected unique unkind unknown unseen unthinkable unwashed upsetting
urgent vain variegated vile vicious volatile wanton wary wasteful whispering
weathered wicked wild wintry wise withered wondrous young
""".split()

TARGETS = """
abyss accord ancients ambrosia annulet apocalypse basin battle beach bedrock
bluff bog bordello bottle breeze brooch brook bush bute cave channel cliff
cloud clover corruption cavern chasm chronicle cloud cobweb colloquy cove creek
cult dasein debris dew dome doom dream dust eddy edge ember emblem experiment
faerie fen field figurine fire firefly fireplace fissure flower fog forest
fountain frog frost funeral gestalt geyser gift glacier glade glen gorge grass
heart herbs hill home horizon imprecation inlet isle isthmus jar karma knell
knight lake laurel leaf locus luster marble marsh meadow mesa mire moon
mountain moss necropolis oasis ocean oubliette overwatch palimpsest paper
passage peak petricor phyle picture pine plenum poet pond poignard portent
praxis quest rain redoubt reef remnant resonance river road sacrifice scent sea
seed shadow shaft shelter shield silence spirit sky smoke snow soldier sorrow
sound star staircase sun surf surface swamp tempest thought threshold thunder
torment tower treasure tree triptych trove tunnel vacuum valediction vengeance
voice volcano water waterfall wave wind wood world zombie
""".split()

TIME_NAMES = """
afterlight afternoon autumn crescent dawn daybreak daylight dusk equinox
evening eventide gibbous gloaming harvest midday midnight moonrise moonset morning
night nightfall noon noontide solstice spring summer sunrise sunset twilight
vespertine winter zenith
""".split()

def generate_name(seed):
    random.seed(seed)

    descriptor = random.choice(DESCRIPTORS)
    time_name = random.choice(TIME_NAMES)
    target = random.choice(TARGETS)

    return '-'.join([descriptor, time_name, target])

def get_system_uuid():
    try:
        output = subprocess.check_output(['dmidecode', '-s', 'system-uuid'], text=True)
        uuid = output.strip()

        if re.match(r'^[0-9A-Fa-f\-]+$', uuid):
            return uuid
    except Exception as e:
        print(f"error accessing system UUID via dmidecode: {e}")

    raise "unknown-identifier"

def uuid_to_seed(uuid):
    return int(uuid.replace('-', ''), 16)

uuid = get_system_uuid()
seed = uuid_to_seed(uuid)

print(generate_name(seed))
