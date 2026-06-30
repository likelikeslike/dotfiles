# Python Coding Style Guide

> PEP8 compliant, Python 3.11+ typing conventions

---

## 1. Formatting

### Indentation
* Use 4 spaces per indentation level
* Never use tabs
* Continuation lines: use hanging indent only

```python
# Hanging indent (4 spaces)
def long_function_name(
    var_one: str,
    var_two: int,
    var_three: float,
) -> None:
    print(var_one)
```

### Line Length
* Maximum 88 characters (Black default)
* Docstrings/comments: maximum 72 characters

### Blank Lines
* 2 blank lines: top-level function/class definitions
* 1 blank line: method definitions inside a class
* Use sparingly inside functions to indicate logical sections

### Imports

**Order (separated by blank lines):**
1. Standard library
2. Third-party packages
3. Local application imports

```python
import os
import sys
from collections.abc import Callable, Iterable, Mapping
from pathlib import Path

import httpx
from pydantic import BaseModel

from myapp.core import config
from myapp.utils import helpers
```

**Rules:**
* One import per line for `import x`
* Multiple imports allowed for `from x import a, b, c`
* Use absolute imports; avoid relative imports
* Never use `from module import *`

---

## 2. Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Module | `snake_case` | `data_loader.py` |
| Package | `snake_case` | `my_package` |
| Class | `PascalCase` | `DataProcessor` |
| Function | `snake_case` | `process_data()` |
| Variable | `snake_case` | `user_count` |
| Constant | `SCREAMING_SNAKE_CASE` | `MAX_RETRIES` |
| Type Variable | `PascalCase` | `T`, `KeyType` |
| Private | `_leading_underscore` | `_internal_cache` |
| "Dunder" | `__double_underscore__` | `__init__` |

### Naming Rules
* Avoid single-letter names except: `i`, `j`, `k` for indices; `x`, `y`, `z` for coordinates; `e` for exceptions; `f` for files; `T` for type vars
* Be descriptive but concise
* Boolean variables: use `is_`, `has_`, `can_`, `should_` prefixes

```python
is_valid: bool = True
has_permission: bool = False
can_edit: bool = True
should_retry: bool = False
```

---

## 3. Type Hints (Python 3.11+)

### Basic Types

```python
# Built-in types (lowercase, no import needed)
name: str = "Alice"
count: int = 42
ratio: float = 3.14
is_active: bool = True
data: bytes = b"raw"

# None type
result: None = None

# Container types (built-in generics)
names: list[str] = ["Alice", "Bob"]
scores: dict[str, int] = {"Alice": 100}
coordinates: tuple[float, float] = (1.0, 2.0)
unique_ids: set[int] = {1, 2, 3}
frozen_ids: frozenset[int] = frozenset({1, 2, 3})
```

### Union Types (Use `|` operator)

```python
# Python 3.10+ union syntax
value: int | str = 42
optional_name: str | None = None

# Multiple types
result: int | float | str = get_result()
```

### Optional Values

```python
# Prefer explicit union with None
def find_user(user_id: int) -> User | None:
    ...

# Default None parameters
def greet(name: str | None = None) -> str:
    return f"Hello, {name or 'World'}"
```

### Collections from `collections.abc`

```python
from collections.abc import (
    Callable,
    Iterable,
    Iterator,
    Mapping,
    MutableMapping,
    Sequence,
    MutableSequence,
)

def process_items(items: Iterable[int]) -> list[int]:
    return [x * 2 for x in items]

def apply_func(func: Callable[[int, int], int], a: int, b: int) -> int:
    return func(a, b)

def read_config(config: Mapping[str, str]) -> None:
    ...
```

### Type Aliases

```python
# Simple type alias (Python 3.12+ syntax)
type UserId = int
type JsonDict = dict[str, Any]
type Handler = Callable[[Request], Response]

# Python 3.11 compatible (use TypeAlias)
from typing import TypeAlias

UserId: TypeAlias = int
JsonDict: TypeAlias = dict[str, Any]
Handler: TypeAlias = Callable[[Request], Response]
```

### Generics

```python
from typing import TypeVar

T = TypeVar("T")
K = TypeVar("K")
V = TypeVar("V")

def first(items: list[T]) -> T | None:
    return items[0] if items else None

def merge_dicts(a: dict[K, V], b: dict[K, V]) -> dict[K, V]:
    return {**a, **b}
```

### Generic Classes (Python 3.12+ syntax)

```python
# Python 3.12+
class Stack[T]:
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

# Python 3.11 compatible
from typing import Generic, TypeVar

T = TypeVar("T")

class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()
```

### Self Type

```python
from typing import Self

class Builder:
    def set_name(self, name: str) -> Self:
        self.name = name
        return self

    def clone(self) -> Self:
        return type(self)()
```

### Literal Types

```python
from typing import Literal

def set_mode(mode: Literal["read", "write", "append"]) -> None:
    ...

Status: TypeAlias = Literal["pending", "active", "completed"]
```

### TypedDict

```python
from typing import TypedDict, Required, NotRequired

class UserDict(TypedDict):
    id: int
    name: str
    email: str | None

class ConfigDict(TypedDict, total=False):
    debug: bool
    timeout: int
    retries: NotRequired[int]
```

### Protocol (Structural Subtyping)

```python
from typing import Protocol

class Readable(Protocol):
    def read(self, n: int = -1) -> bytes: ...

class Closeable(Protocol):
    def close(self) -> None: ...

class ReadableCloseable(Readable, Closeable, Protocol):
    pass

def process_stream(stream: Readable) -> bytes:
    return stream.read()
```

### Final and ClassVar

```python
from typing import Final, ClassVar

MAX_SIZE: Final[int] = 1024

class Config:
    DEFAULT_TIMEOUT: ClassVar[int] = 30
    name: str
```

### Annotated

```python
from typing import Annotated

PositiveInt = Annotated[int, "must be positive"]
UserId = Annotated[int, "unique user identifier"]

def get_user(user_id: Annotated[int, "valid user ID"]) -> User:
    ...
```

### Overload

```python
from typing import overload

@overload
def process(data: str) -> str: ...
@overload
def process(data: bytes) -> bytes: ...
@overload
def process(data: int) -> int: ...

def process(data: str | bytes | int) -> str | bytes | int:
    if isinstance(data, str):
        return data.upper()
    elif isinstance(data, bytes):
        return data.upper()
    else:
        return data * 2
```

### ParamSpec and Concatenate

```python
from typing import ParamSpec, Concatenate
from collections.abc import Callable

P = ParamSpec("P")

def with_logging(func: Callable[P, T]) -> Callable[P, T]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

def add_context(
    func: Callable[Concatenate[Context, P], T]
) -> Callable[P, T]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
        ctx = Context()
        return func(ctx, *args, **kwargs)
    return wrapper
```

---

## 4. Function Signatures

### General Rules

```python
def function_name(
    required_arg: str,
    optional_arg: int = 0,
    *args: str,
    keyword_only: bool = False,
    **kwargs: Any,
) -> ReturnType:
    """Short description.

    Args:
        required_arg: Description.
        optional_arg: Description. Defaults to 0.
        *args: Additional string arguments.
        keyword_only: Description. Defaults to False.
        **kwargs: Additional keyword arguments.

    Returns:
        Description of return value.

    Raises:
        ValueError: When something is invalid.
    """
    ...
```

### Async Functions

```python
async def fetch_data(url: str, timeout: float = 30.0) -> dict[str, Any]:
    async with httpx.AsyncClient() as client:
        response = await client.get(url, timeout=timeout)
        return response.json()
```

### Generators

```python
from collections.abc import Generator, AsyncGenerator

def count_up(n: int) -> Generator[int, None, None]:
    for i in range(n):
        yield i

async def async_count(n: int) -> AsyncGenerator[int, None]:
    for i in range(n):
        yield i
```

---

## 5. Classes

### Structure Order

```python
class MyClass:
    """Class docstring."""

    # 1. Class variables
    class_var: ClassVar[int] = 0

    # 2. __init__
    def __init__(self, value: int) -> None:
        self.value = value
        self._cache: dict[str, Any] = {}

    # 3. __new__ (if needed)
    # 4. Other dunder methods (__str__, __repr__, __eq__, etc.)

    def __repr__(self) -> str:
        return f"{type(self).__name__}(value={self.value!r})"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, MyClass):
            return NotImplemented
        return self.value == other.value

    # 5. Class methods
    @classmethod
    def from_string(cls, s: str) -> Self:
        return cls(int(s))

    # 6. Static methods
    @staticmethod
    def validate(value: int) -> bool:
        return value >= 0

    # 7. Properties
    @property
    def doubled(self) -> int:
        return self.value * 2

    # 8. Public methods
    def process(self) -> None:
        ...

    # 9. Private methods
    def _internal_method(self) -> None:
        ...
```

### Dataclasses

```python
from dataclasses import dataclass, field

@dataclass
class User:
    id: int
    name: str
    email: str | None = None
    tags: list[str] = field(default_factory=list)

@dataclass(frozen=True, slots=True)
class Point:
    x: float
    y: float

    def distance(self, other: Self) -> float:
        return ((self.x - other.x) ** 2 + (self.y - other.y) ** 2) ** 0.5
```

### Pydantic Models

```python
from pydantic import BaseModel, Field, field_validator

class UserCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    email: str
    age: int = Field(default=0, ge=0)

    @field_validator("email")
    @classmethod
    def validate_email(cls, v: str) -> str:
        if "@" not in v:
            raise ValueError("Invalid email")
        return v.lower()
```

---

## 6. Exception Handling

```python
# Specific exceptions
try:
    result = risky_operation()
except ValueError as e:
    logger.warning("Invalid value: %s", e)
    raise
except (TypeError, KeyError) as e:
    logger.error("Unexpected error: %s", e)
    raise RuntimeError("Operation failed") from e
finally:
    cleanup()

# Context managers
from contextlib import contextmanager

@contextmanager
def managed_resource() -> Generator[Resource, None, None]:
    resource = acquire_resource()
    try:
        yield resource
    finally:
        resource.release()
```

### Custom Exceptions

```python
class AppError(Exception):
    """Base exception for application."""

class ValidationError(AppError):
    """Raised when validation fails."""

    def __init__(self, field: str, message: str) -> None:
        self.field = field
        self.message = message
        super().__init__(f"{field}: {message}")
```

---

## 7. Docstrings

Use Google style docstrings.

### Module

```python
"""Short module description.

Longer description if needed. Explain the module's purpose
and main components.

Examples:
    Basic usage example::

        from mymodule import process
        result = process(data)
"""
```

### Function

```python
def process_data(
    data: list[dict[str, Any]],
    threshold: float = 0.5,
) -> list[dict[str, Any]]:
    """Process and filter data based on threshold.

    Args:
        data: List of dictionaries to process.
        threshold: Minimum score to include. Defaults to 0.5.

    Returns:
        Filtered list of dictionaries with score >= threshold.

    Raises:
        ValueError: If data is empty or threshold is negative.

    Examples:
        >>> process_data([{"score": 0.8}, {"score": 0.3}])
        [{"score": 0.8}]
    """
```

### Class

```python
class DataProcessor:
    """Process and transform data records.

    Handles validation, transformation, and output formatting
    for data records.

    Attributes:
        config: Processing configuration.
        stats: Processing statistics.

    Examples:
        >>> processor = DataProcessor(config)
        >>> processor.process(records)
    """
```

---

## 8. Best Practices

### Use Pathlib

```python
from pathlib import Path

config_path = Path("config") / "settings.json"
if config_path.exists():
    content = config_path.read_text()
```

### Use f-strings

```python
name = "Alice"
count = 42

# Preferred
message = f"Hello, {name}! Count: {count}"

# Debug (Python 3.8+)
print(f"{name=}, {count=}")  # name='Alice', count=42

# Do NOT use f-strings for logging
logger.info("User %s has count %d", name, count)
```

### Use Context Managers

```python
# File handling
with open("file.txt") as f:
    content = f.read()

# Multiple resources
with open("in.txt") as fin, open("out.txt", "w") as fout:
    fout.write(fin.read())

# Async context managers
async with httpx.AsyncClient() as client:
    response = await client.get(url)
```

### Use Comprehensions Wisely

```python
# Good: simple transformations
squares = [x**2 for x in range(10)]
even_squares = [x**2 for x in range(10) if x % 2 == 0]
name_map = {user.id: user.name for user in users}

# Bad: complex logic (use regular loop)
# results = [process(x) for x in items if validate(x) and transform(x)]

# Better
results = []
for x in items:
    if validate(x) and transform(x):
        results.append(process(x))
```

### Avoid Mutable Default Arguments

```python
# Wrong
def append_to(item: int, target: list[int] = []) -> list[int]:
    target.append(item)
    return target

# Correct
def append_to(item: int, target: list[int] | None = None) -> list[int]:
    if target is None:
        target = []
    target.append(item)
    return target
```

### Use `__all__` for Public API

```python
__all__ = [
    "PublicClass",
    "public_function",
    "PUBLIC_CONSTANT",
]
```

---

## 9. Tools Configuration

### pyproject.toml

```toml
[project]
requires-python = ">=3.11"

[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # Pyflakes
    "I",    # isort
    "B",    # flake8-bugbear
    "C4",   # flake8-comprehensions
    "UP",   # pyupgrade
    "SIM",  # flake8-simplify
    "TCH",  # flake8-type-checking
    "RUF",  # Ruff-specific
]
ignore = ["E501"]  # line length handled by formatter

[tool.ruff.lint.isort]
known-first-party = ["myapp"]
```

---

## 10. Quick Reference

### Type Hint Cheat Sheet

| Type | Syntax |
|------|--------|
| Optional | `str \| None` |
| Union | `int \| str \| float` |
| List | `list[str]` |
| Dict | `dict[str, int]` |
| Tuple (fixed) | `tuple[int, str, float]` |
| Tuple (variable) | `tuple[int, ...]` |
| Callable | `Callable[[int, str], bool]` |
| Any | `Any` (from typing) |
| Self | `Self` (from typing) |

### Import Sources

| Import From | Types |
|-------------|-------|
| Built-in | `list`, `dict`, `tuple`, `set`, `frozenset` |
| `typing` | `Any`, `TypeVar`, `Self`, `Final`, `ClassVar`, `Literal`, `TypedDict`, `Protocol`, `overload`, `TypeAlias` |
| `collections.abc` | `Callable`, `Iterable`, `Iterator`, `Mapping`, `Sequence`, `Generator`, `AsyncGenerator` |
