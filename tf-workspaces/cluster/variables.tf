
# Feed from secrets.auto.tfvars
variable "hcloud_token" {}
variable "do_token" {}

# fed from Variable sets in Terraform cloud
variable "hcloud_token_ro" {
  type = string
}

variable "domain" {
  type = string
  default = "workshop.o11ystack.org"
  description = "The domain to register the pet servers with"
}

variable "acme_email_address" {
  type = string
  default = "nobody@o11ystack.org"
  description = "The email to register the ACME account with"
}

variable "instance_create_count" {
  type = number
  default = 2
  description = "The number of instances to create. Must be a subset or equal to the number of server_names."
}

locals {
  instance_server_names = toset(slice(var.server_names, 0, var.instance_create_count))
}

variable "server_names" {
  description = "The list of petnames to seed from"
  type = list(string)
  default = [
    "credible-alpaca",
    "evolving-lionfish",
    "closing-chicken",
#    "holy-hog",
#    "wired-lizard",
#    "flowing-tadpole",
#    "touched-firefly",
#    "super-eft",
#    "unique-pony",
#    "meet-moose",
#    "next-camel",
#    "proper-bull",
#    "fine-seal",
#    "brave-molly",
#    "touched-camel",
#    "trusting-garfish",
#    "solid-toucan",
#    "giving-panda",
#    "informed-wildcat",
#    "hopeful-chamois",
#    "choice-fox",
#    "hardy-gnu",
#    "rational-akita",
#    "unique-osprey",
#    "teaching-perch",
#    "generous-starfish",
#    "quality-terrapin",
#    "driven-javelin",
#    "legal-ringtail",
#    "adapted-cat",
#    "crack-finch",
#    "above-kangaroo",
#    "thorough-lark",
#    "relevant-lion",
#    "divine-kid",
#    "peaceful-firefly",
#    "cheerful-dinosaur",
#    "workable-pangolin",
#    "equipped-octopus",
#    "hip-kiwi",
#    "handy-condor",
#    "elegant-frog",
#    "pleasing-crayfish",
#    "divine-cowbird",
#    "peaceful-skunk",
#    "sound-hound",
#    "dynamic-fish",
#    "electric-silkworm",
#    "aware-ringtail",
#    "golden-mink",
#    "well-firefly",
#    "complete-silkworm",
#    "patient-lab",
#    "easy-blowfish",
#    "inviting-reptile",
#    "current-mayfly",
#    "amusing-mongrel",
#    "exotic-kit",
#    "simple-guinea",
#    "generous-alpaca",
#    "nice-manatee",
#    "equal-hippo",
#    "fast-dragon",
#    "loyal-moth",
#    "massive-tadpole",
#    "tough-aardvark",
#    "loved-mite",
#    "cute-puma",
#    "busy-mako",
#    "relevant-eel",
#    "quiet-bird",
#    "resolved-gull",
#    "ethical-fly",
#    "famous-iguana",
#    "good-pig",
#    "worthy-rat",
#    "trusty-opossum",
#    "enhanced-octopus",
#    "inviting-frog",
#    "allowed-platypus",
#    "national-mole",
#    "patient-griffon",
#    "optimum-macaque",
#    "sincere-pelican",
#    "promoted-egret",
#    "apt-drum",
#    "eminent-insect",
#    "evolved-lamb",
#    "primary-puma",
#    "composed-moth",
#    "welcome-termite",
#    "charming-bear",
#    "assured-moray",
#    "stirred-starfish",
#    "loving-puma",
#    "useful-mantis",
#    "welcome-ostrich",
#    "strong-cod",
#    "nice-condor",
#    "still-gar",
#    "blessed-glowworm",
#    "tender-wallaby",
#    "right-earwig",
#    "master-bengal",
#    "giving-skylark",
#    "bright-clam",
#    "promoted-narwhal",
#    "logical-oryx",
#    "welcomed-dove",
#    "alive-clam",
#    "healthy-honeybee",
#    "giving-shiner",
#    "tender-corgi",
#    "driven-donkey",
#    "social-rodent",
#    "content-cod",
#    "eager-lizard",
#    "careful-gazelle",
#    "glorious-sole",
#    "genuine-whippet",
#    "hopeful-toad",
#    "assuring-treefrog",
#    "pleased-silkworm",
#    "boss-gazelle",
#    "polite-louse",
#    "free-rhino",
#    "sharing-sculpin",
#    "harmless-clam",
#    "able-redfish",
#    "adapting-dory",
#    "busy-silkworm",
#    "eminent-dog",
#    "liberal-starling",
#    "precise-meerkat",
#    "chief-penguin",
#    "hopeful-cobra",
#    "cosmic-llama",
#    "stirring-raptor",
#    "content-blowfish",
#    "fancy-dolphin",
#    "ace-basilisk",
#    "enhanced-lion",
#    "artistic-pheasant",
#    "correct-buffalo",
#    "one-sheepdog",
#    "selected-wolf",
#    "frank-gecko",
#    "ruling-fawn",
#    "complete-mantis",
#    "dynamic-beetle",
#    "loved-werewolf",
#    "equipped-jackal",
#    "charming-martin",
#    "vital-rooster",
#    "fun-tuna",
#    "worthy-caribou",
#    "tight-lacewing",
#    "climbing-reptile",
#    "select-malamute",
#    "still-lab",
#    "ultimate-perch",
#    "magnetic-jay",
#    "concise-coral",
#    "profound-filly",
#    "up-fowl",
#    "upright-dory",
#    "mature-bobcat",
#    "cheerful-sunbird",
#    "comic-whale",
#    "moved-terrier",
#    "proven-swan",
#    "flying-corgi",
#    "intent-mayfly",
#    "more-sawfish",
#    "adjusted-turtle",
#    "first-lynx",
#    "integral-troll",
#    "daring-tahr",
#    "enabling-racer",
#    "patient-redbird",
#    "top-gar",
#    "deciding-bobcat",
#    "pumped-louse",
#    "evolved-goshawk",
#    "humorous-koi",
#    "busy-pigeon",
#    "obliging-heron",
#    "guided-polecat",
#    "sharp-oriole",
#    "daring-goshawk",
#    "rested-mantis",
#    "expert-rooster",
#    "strong-phoenix",
#    "credible-fox",
#    "smashing-gull",
#    "relieved-seagull",
#    "one-hyena",
#    "feasible-katydid",
#    "definite-owl",
#    "stirring-goshawk"
  ]
}