
string commentIndex[];
string comments[];

void jComment(string index, string comment) {
    int indexFound = -1;
    for (int i = 0; i < ArraySize(comments); i ++) {
        if (commentIndex[i] == index){
            indexFound = i;
        }
    }

    if (indexFound == -1) {
        indexFound = ArraySize(commentIndex);
        Push(commentIndex, index);
        ArrayResize(comments, ArraySize(comments)+1);
    }
    comments[indexFound] = comment;
    
    
    doComment();
}


void doComment() {
    string toComment = "";
    for (int i = 0; i < ArraySize(comments); i ++) {
        toComment = StringConcatenate(toComment, commentIndex[i], ": ", comments[i], "\n");
    }
    Comment(toComment);
}