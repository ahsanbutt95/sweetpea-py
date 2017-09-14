data HLBlock = HLBlock { hlnumTrials :: Int
                       , hldesign :: Design
                       , hlconstraints :: [HLConstraint]
                       } deriving(Show)

type Design = [HLLabelTree]
data HLLabelTree = NTNode String [HLLabelTree] | LeafNode String deriving(Show)

type HLAST = [HLBlock]

data HLConstraint =  HLAssertEq Int [String] --TODO: the list of string rep, what does that mean?
                   | HLAssertLt Int [String]
                   | HLAssertGt Int [String]
                   | Consistency
                   | FullyCross deriving(Show)


                  --  data HLBlock = HLBlock { hlnumTrials :: Int
                  --                         , hldesign :: Design
                  --                         , hlconstraints :: [HLConstraint]
                  --                         } deriving(Show)

makeBlock :: Int -> Design -> [HLConstraint] -> HLBlock
makeBlock numTs des consts = (HLBlock numTs des (Consistency : consts))


-- color = NTNode "color" [(NTNode "darkcolor" [(LeafNode "black"), (LeafNode "blue")]), (NTNode "lightcolor" [(LeafNode "blue"), (LeafNode "pink")])]
-- shape = NTNode "shape" [(LeafNode "circle"), (LeafNode "square"), (LeafNode "triangle")]
-- design = [color, shape]
-- block = makeBlock (hlFullyCross design) [color, shape] [FullyCross]
-- ast = [block, block]
-- hlToIl ast

-- tests
-- countLeaves color == 4
-- countLeaves shape == 3
-- countLeaves (LeafNode "a") == 1
countLeaves :: HLLabelTree -> Int
countLeaves (NTNode _ children) = foldl (\acc x -> acc + countLeaves x) 0 children
countLeaves (LeafNode _) = 1

totalLeavesInDesign :: Design -> Int
totalLeavesInDesign design = foldl (\acc x -> acc + countLeaves x) 0 design

-- only tells you the NUMBER of TRIALS
hlFullyCross :: Design -> Int
hlFullyCross factors = numStates
  where numStates = foldl (\acc x -> acc * countLeaves x) 1 factors


type Count = Int
type Var = Int
-- Transformation time!
hlToIl :: HLAST -> ILAST
hlToIl ast = go ast 1
  where go :: HLAST -> Int -> ILAST
        go (curr:[]) fresh = [(allocateVars curr fresh)]
        go (curr:rest) fresh = ilblock : (go rest newFresh)
            where ilblock = allocateVars curr fresh
                  newFresh = (ilendAddr ilblock) + 1



allocateVars :: HLBlock -> Int -> ILBlock
allocateVars (HLBlock numTrials design constraints) fresh = (ILBlock numTrials startAddr endAddr design constraints)
  where startAddr = fresh
        trialSize = totalLeavesInDesign design
        endAddr = fresh + (numTrials * trialSize) - 1


-- list of IL blocks : get the total num allocated by looking at last block
type ILAST = [ILBlock]

-- so a block that occupies: 0, 1, 2, 3 the startAddr is 0 & the endAddr is 3
data ILBlock = ILBlock { ilnumTrials :: Int
                       , ilstartAddr :: Int
                       , ilendAddr :: Int
                       , ildesign :: Design
                       , ilconstraints :: [HLConstraint]
                       } deriving(Show)


--- Transformation time!
-- TODO: It's constraint time. How are constraints going to be represented?
-- 1. Start up the State(Int, CNF)
-- 2. Variable alloc for FC & fully cross => equate states with variable combos
-- 3.
data LLConstraint = AssertEq Int [Var] | AssertLt Int [Var]
                  | AssertGt Int [Var] | OneHot [Var]
                  | Entangle Var [Var]

-- list of IL blocks : get the total num allocated by looking at last block
type LLAST = [LLBlock]


data LLBlock = LLBlock { llconstraints :: [LLConstraint]
                       } deriving(Show)


-- TODO: desugar the other constraints from HLConstraints to LLConstraints using Design
ilToll :: ILAST -> LLAST
ilToll ast = []

ilBlockToLLBlock :: ILBlock -> LLBlock
ilBlockToLLBlock inBlock = (LLBlock [])

desugarConstraint :: HLConstraint -> ILBlock -> LLBlock
desugarConstraint Consistency inBlock = (LLBlock [])
desugarConstraint FullyCross  inBlock = (LLBlock [])
desugarConstraint _ inBlock = error "desugar const not implemented yet"
