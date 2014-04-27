cdef getdata(self, Pattern pattern):
    cdef cIndexedData cvalue
    if pattern in self:
        cvalue = self.data[pattern.cpattern]
        value = IndexedData()
        value.bind(cvalue)
        return value
    else:
        raise KeyError


cpdef add(self, Pattern pattern, indices):
    """Add a pattern to the indexed model
    :param pattern: The pattern to add
    :type pattern: Pattern
    :param indices: list (or other iterable) of 2-tuples specifying the (sentence,index) of each occurrence of the pattern
    """

    cdef cIndexedData * cvalue
    cvalue = &(self.data[pattern.cpattern])
    cdef cIndexReference ref
    for sentence,token in indices:
        ref.sentence = <int> sentence
        ref.token = <int> token
    self.data.add(pattern.cpattern, cvalue, ref)

def __iter__(self):
    """Iterate over all patterns in this model"""
    it = self.data.begin()
    cdef cPattern cpattern
    while it != self.data.end():
        cpattern = deref(it).first
        pattern = Pattern()
        pattern.bind(cpattern)
        yield pattern
        inc(it)

def items(self):
    """Iterate over all patterns and their index data (IndexedData instances) in this model"""
    it = self.data.begin()
    cdef cPattern cpattern
    cdef cIndexedData cvalue
    while it != self.data.end():
        cpattern = deref(it).first
        cvalue = deref(it).second
        pattern = Pattern()
        pattern.bind(cpattern)
        value = IndexedData()
        value.bind(cvalue)
        yield (pattern,value)
        inc(it)



def reverseindex(self, indexreference):
    """Generator over all patterns occurring at the specified index reference

    :param indexreference: a (sentence, tokenoffset) tuple
    """

    if not isinstance(indexreference, tuple) or not len(indexreference) == 2:
        raise ValueError("Expected tuple")

    cdef int sentence = indexreference[0]
    cdef int token = indexreference[1]
    cdef cIndexReference ref = cIndexReference(sentence, token)
    cdef vector[cPattern] results = self.data.getreverseindex(ref)
    cdef vector[cPattern].iterator resit = results.begin()
    cdef cPattern cpattern
    while resit != results.end():
        cpattern = deref(resit)
        pattern = Pattern()
        pattern.bind(cpattern)
        yield pattern
        inc(resit)


def covered(self, indexreference):
    if not isinstance(indexreference, tuple) or not len(indexreference) == 2:
        raise ValueError("Expected tuple")
    cdef int sentence = indexreference[0]
    cdef int token = indexreference[1]
    cdef cIndexReference ref = cIndexReference(sentence, token)
    cdef cIndexReference ref2
    cdef vector[cPattern] results = self.data.getreverseindex(ref)
    cdef vector[cPattern] results2
    cdef vector[cPattern].iterator resit
    cdef cPattern cpattern
    if not results.empty():
        return True
    else:
        for i in range(1, token+1):
            if token-i >= 0:
                ref2 = cIndexReference(sentence, token-i)
                results2 = self.data.getreverseindex(ref2)
                resit = results2.begin()
                while resit != results2.end():
                    cpattern = deref(resit)
                    if cpattern.n() >= token+1:
                        return True
                    inc(resit)
        return False






def reverseindex_bysentence(self, int sentence):
    """Generator over all patterns occurring in the specified sentence

    :param sentence: a sentence number
    """

    cdef vector[pair[cIndexReference,cPattern]] results = self.data.getreverseindex_bysentence(sentence)
    cdef vector[pair[cIndexReference,cPattern]].iterator resit = results.begin()
    cdef pair[cIndexReference,cPattern] p
    cdef cPattern cpattern
    while resit != results.end():
        p = deref(resit)
        pattern = Pattern()
        pattern.bind(p.second)
        yield (p.first.sentence, p.first.token), pattern
        inc(resit)

cpdef outputrelations(self, Pattern pattern, ClassDecoder decoder):
    """Compute and output (to stdout) all relations for the specified pattern:

    :param pattern: The pattern to output relations for
    :type pattern: Pattern
    :param decoder: The class decoder
    :type decoder: ClassDecoder
    """
    self.data.outputrelations(pattern.cpattern,decoder.data,&cout)


def getsubchildren(self, Pattern pattern):
    """Get subsumption children for the specified pattern
    :param pattern: The pattern
    :type pattern: Pattern
    :rtype: generator over (Pattern,value) tuples. The values correspond to the number of occurrences for this particularrelationship
    """
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long]  relations = self.data.getsubchildren(pattern.cpattern)
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long].iterator relit = relations.begin()

    cdef cPattern cpattern
    cdef int value
    while relit != relations.end():
        cpattern = deref(relit).first
        value = deref(relit).second
        pattern = Pattern()
        pattern.bind(cpattern)
        yield (pattern,value)
        inc(relit)

def getsubparents(self, Pattern pattern):
    """Get subsumption parents for the specified pattern
    :param pattern: The pattern
    :type pattern: Pattern
    :rtype: generator over (Pattern,value) tuples. The values correspond to the number of occurrences for this particularrelationship
    """
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long]  relations = self.data.getsubparents(pattern.cpattern)
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long].iterator relit = relations.begin()
    cdef cPattern cpattern
    cdef int value
    while relit != relations.end():
        cpattern = deref(relit).first
        value = deref(relit).second
        pattern = Pattern()
        pattern.bind(cpattern)
        yield (pattern,value)
        inc(relit)

def getleftneighbours(self, Pattern pattern):
    """Get left neighbours for the specified pattern
    :param pattern: The pattern
    :type pattern: Pattern
    :rtype: generator over (Pattern,value) tuples. The values correspond to the number of occurrences for this particularrelationship
    """
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long]  relations = self.data.getleftneighbours(pattern.cpattern)
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long].iterator relit = relations.begin()
    cdef cPattern cpattern
    cdef int value
    while relit != relations.end():
        cpattern = deref(relit).first
        value = deref(relit).second
        pattern = Pattern()
        pattern.bind(cpattern)
        yield (pattern,value)
        inc(relit)

def getrightneighbours(self, Pattern pattern):
    """Get right neighbours for the specified pattern
    :param pattern: The pattern
    :type pattern: Pattern
    :rtype: generator over (Pattern,value) tuples. The values correspond to the number of occurrences for this particularrelationship
    """
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long]  relations = self.data.getrightneighbours(pattern.cpattern)
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long].iterator relit = relations.begin()
    cdef cPattern cpattern
    cdef int value
    while relit != relations.end():
        cpattern = deref(relit).first
        value = deref(relit).second
        pattern = Pattern()
        pattern.bind(cpattern)
        yield (pattern,value)
        inc(relit)

def getskipcontent(self, Pattern pattern):
    """Get skip content for the specified pattern
    :param pattern: The pattern
    :type pattern: Pattern
    :rtype: generator over (Pattern,value) tuples. The values correspond to the number of occurrence for this particularrelationship
    """
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long]  relations = self.data.getskipcontent(pattern.cpattern)
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long].iterator relit = relations.begin()
    cdef cPattern cpattern
    cdef int value
    while relit != relations.end():
        cpattern = deref(relit).first
        value = deref(relit).second
        pattern = Pattern()
        pattern.bind(cpattern)
        yield (pattern,value)
        inc(relit)

def gettemplates(self, Pattern pattern):
    """Get templates (abstracting skipgrams) for the specified pattern
    :param pattern: The pattern
    :type pattern: Pattern
    :rtype: generator over (Pattern,value) tuples. The values correspond to the number of occurrence for this particularrelationship
    """
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long]  relations = self.data.gettemplates(pattern.cpattern)
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long].iterator relit = relations.begin()
    cdef cPattern cpattern
    cdef int value
    while relit != relations.end():
        cpattern = deref(relit).first
        value = deref(relit).second
        pattern = Pattern()
        pattern.bind(cpattern)
        yield (pattern,value)
        inc(relit)

def getleftcooc(self, Pattern pattern):
    """Get left-side co-occurrences for the specified pattern
    :param pattern: The pattern
    :type pattern: Pattern
    :rtype: generator over (Pattern,value) tuples. The values correspond to the number of occurrence for this particularrelationship
    """
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long]  relations = self.data.getleftcooc(pattern.cpattern)
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long].iterator relit = relations.begin()
    cdef cPattern cpattern
    cdef int value
    while relit != relations.end():
        cpattern = deref(relit).first
        value = deref(relit).second
        pattern = Pattern()
        pattern.bind(cpattern)
        yield (pattern,value)
        inc(relit)

def getrightcooc(self, Pattern pattern):
    """Get left-side co-occurrences for the specified pattern
    :param pattern: The pattern
    :type pattern: Pattern
    :rtype: generator over (Pattern,value) tuples. The values correspond to the number of occurrence for this particularrelationship
    """
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long]  relations = self.data.getrightcooc(pattern.cpattern)
    cdef cPatternMap[unsigned int,cBaseValueHandler[uint],unsigned long].iterator relit = relations.begin()
    cdef cPattern cpattern
    cdef int value
    while relit != relations.end():
        cpattern = deref(relit).first
        value = deref(relit).second
        pattern = Pattern()
        pattern.bind(cpattern)
        yield (pattern,value)
        inc(relit)
