//
//  matrix2d.swift
//  swix
//
//  Created by Scott Sievert on 7/9/14.
//  Copyright (c) 2014 com.scott. All rights reserved.
//

import Foundation
import Accelerate
struct matrix2d {
    let n: Int
    var rows: Int
    var columns: Int
    var count: Int
    var shape: (Int, Int)
    var flat:matrix
    init(columns: Int, rows: Int) {
        self.n = rows * columns
        self.rows = rows
        self.columns = columns
        self.shape = (rows, columns)
        self.count = n
        self.flat = zeros(rows * columns)
        
    }
    subscript(i: String) -> matrix {
        get {
            assert(i == "diag", "Currently the only support x[string] is x[\"diag\"]")
            var x = diag(self)
            return x
        }
        set {
            assert(i == "diag")
            diag_set_objc(!self, !newValue, self.shape.0.cint, self.shape.1.cint)
        }
    }
    func indexIsValidForRow(r: Int, c: Int) -> Bool {
        return r >= 0 && r < rows && c>=0 && c < columns
    }
    subscript(i: Int, j: Int) -> Double {
        get {
            assert(indexIsValidForRow(i, c:j), "Index out of range")
            return flat[i*columns + j]
        }
        set {
            assert(indexIsValidForRow(i, c:j), "Index out of range")
            flat[i*columns + j] = newValue
        }
    }
    subscript(r: Range<Int>, c: Range<Int>) -> matrix2d {
        get {
            var rr = toArray(r)
            var cc = toArray(c)
            var (j, i) = meshgrid(rr, cc)
            var idx = (j.flat*columns.double + i.flat)
            var z = flat[idx]
            var zz = reshape(z, (rr.n, cc.n))
            return zz
        }
        set {
            var rr = toArray(r)
            var cc = toArray(c)
            var (j, i) = meshgrid(rr, cc)
            var idx = j.flat*columns.double + i.flat
            flat[idx] = newValue.flat
        }
    }
    subscript(r: matrix, c: matrix) -> matrix2d {
        get {
            var (j, i) = meshgrid(r, c)
            var idx = (j.flat*columns.double + i.flat)
            var z = flat[idx]
            var zz = reshape(z, (r.n, c.n))
            return zz
        }
        set {
            var (j, i) = meshgrid(r, c)
            var idx = j.flat*columns.double + i.flat
            flat[idx] = newValue.flat
        }
    }
    subscript(r: matrix) -> matrix {
        get {return self.flat[r]}
        set {flat.grid = newValue.grid}
    }
    subscript(i: Range<Int>, k: Int) -> matrix {
        get {
            var idx = toArray(i)
            var x:matrix = self.flat[idx * self.columns.double + k.double]
            return x
        }
        set {
            var idx = toArray(i)
            self.flat[idx * self.columns.double + k.double] = newValue[idx]
        }
    }
    subscript(i: Int, k: Range<Int>) -> matrix {
        get {
            var idx = toArray(k)
            var x:matrix = self.flat[i.double * self.columns.double + idx]
            return x
        }
        set {
            var idx = toArray(k)
            self.flat[i.double * self.columns.double + idx] = newValue[idx]
        }
    }
}

func println(x: matrix2d, prefix:String="matrix([", postfix:String="])", newline:String="\n", format:String="%.3f", printWholeMatrix:Bool=false){
    print(prefix)
    var suffix = ", "
    var pre:String
    var post:String
    var printedSpacer = false
    for i in 0..<x.shape.0{
        // pre and post nice -- internal variables
        if i==0 {pre = ""}
        else {pre = "        "}
        if i==x.shape.0-1{post=""}
        else {post = "],\n"}
        
        if printWholeMatrix || x.shape.0 < 16 || i<4-1 || i>x.shape.0-4{
            print(x[i, 0..<x.shape.1], prefix:pre, postfix:post, format: format, printWholeMatrix:printWholeMatrix)
        }
        else if printedSpacer==false{
            printedSpacer=true
            println("        ...,")
        }
    }
    print(postfix)
    print(newline)
}
func print(x: matrix2d, prefix:String="matrix([", postfix:String="])", newline:String="\n", format:String="%.3f", printWholeMatrix:Bool=false){
    println(x, prefix:prefix, postfix:postfix, newline:"", format:format, printWholeMatrix:printWholeMatrix)
}
func zeros_like(x: matrix2d) -> matrix2d{
    var y:matrix2d = zeros((x.shape.0, x.shape.1))
    return y
}
func transpose (x: matrix2d) -> matrix2d{
    let n = x.shape.0
    let m = x.shape.1
    var y = zeros((m, n))
    var xP = matrixToPointer(x.flat)
    var yP = matrixToPointer(y.flat)
    transpose_objc(xP, yP, m.cint, n.cint);
    return y
}
func argwhere(idx: matrix2d) -> matrix{
    return argwhere(idx.flat)
}
func copy(x: matrix2d, y: matrix2d){
    copy(x.flat, y.flat)
}


















