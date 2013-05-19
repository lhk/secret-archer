package vector2

type Vector2 struct {
	X float64
	Y float64
}

func (v *Vector2) Add(b Vector2) {
	v.X += b.X
	v.Y += b.Y
}

func (v *Vector2) Sub(b Vector2) {
	v.X += b.X
	v.Y += b.Y
}

func (v *Vector2) Scale(s float64) {
	v.X *= s
	v.Y *= s
}

func Add(a, b Vector2) Vector2 {
	return Vector2{a.X + b.X, a.Y + b.Y}
}

func Sub(a, b Vector2) Vector2 {
	return Vector2{a.X - b.X, a.Y - b.Y}
}

func Scale(a Vector2, b float64) Vector2 {
	return Vector2{a.X * b, a.Y * b}
}
