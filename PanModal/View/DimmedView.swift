//
//  DimmedView.swift
//  PanModal
//
//  Copyright © 2017 Tiny Speck, Inc. All rights reserved.
//

#if os(iOS)
import UIKit

/**
 A dim view for use as an overlay over content you want dimmed.
 */
public class DimmedView: UIView {
    
    // MARK: - Internal types
    
    /**
     Represents the possible states of the dimmed view.
     max, off or a percentage of dimAlpha.
     */
    enum DimState {
        case max
        case off
        case percent(CGFloat)
    }
    
    // MARK: - Internal properties
    
    /**
     The state of the dimmed view
     */
    var dimState: DimState = .off {
        didSet {
            switch dimState {
            case .max:
                alpha = 1.0
            case .off:
                alpha = 0.0
            case .percent(let percentage):
                alpha = max(0.0, min(1.0, percentage))
            }
        }
    }
    
    /**
     The closure to be executed when a tap occurs
     */
    var didTap: ((_ recognizer: UIGestureRecognizer) -> Void)?
    
    /**
     Flag responsible for the ability to forward touches to the delegate
     */
    var canPassTouches = false
    
    // MARK: - Private properties
    /**
     Tap gesture recognizer
     */
    private let dimColor: UIColor
    private lazy var tapGesture  = makeTapGestureRecognizer()
    private weak var touchesDelegateView: UIView?
    
    // MARK: - Initializers

    init(
        dimColor: UIColor = UIColor.black.withAlphaComponent(0.7),
        touchesDelegateView: UIView?
    ) {
        self.dimColor = dimColor
        self.touchesDelegateView = touchesDelegateView
        
        super.init(frame: .zero)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Public methods
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        
        guard let touchesDelegateView, view === self, canPassTouches else {
            return view
        }
        
        return touchesDelegateView.hitTest(
            touchesDelegateView.convert(point, from: self),
            with: event
        )
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        
        alpha = 0.0
        backgroundColor = dimColor
        
        if touchesDelegateView == nil {
            addGestureRecognizer(tapGesture)
        } else {
            isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Event Handlers

    @objc
    private func didTapView() {
        didTap?(tapGesture)
    }
}

// MARK: - Factory

private extension DimmedView {
    
    func makeTapGestureRecognizer() -> UITapGestureRecognizer {
        UITapGestureRecognizer(
            target: self,
            action: #selector(didTapView)
        )
    }
}
#endif
